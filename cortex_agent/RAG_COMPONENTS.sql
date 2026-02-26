-- RAG Components for PDF Document Q&A
-- This creates the infrastructure for Retrieval Augmented Generation from PDF reports

USE ROLE ACCOUNTADMIN;
USE DATABASE COLM_DB;
USE SCHEMA UNSTRUCTURED;
USE WAREHOUSE ADHOC_WH;

-- Step 1: Create table to store document chunks
CREATE OR REPLACE TABLE DOCS_CHUNKS_TABLE (
    RELATIVE_PATH VARCHAR(16777216),
    SIZE NUMBER(38,0),
    FILE_URL VARCHAR(16777216),
    SCOPED_FILE_URL VARCHAR(16777216),
    CHUNK VARCHAR(16777216),
    CHUNK_INDEX NUMBER(38,0),
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Step 2: Create PDF chunker function
CREATE OR REPLACE FUNCTION PDF_TEXT_CHUNKER(file_url VARCHAR)
RETURNS TABLE (chunk VARCHAR, chunk_index NUMBER)
LANGUAGE PYTHON
RUNTIME_VERSION = '3.11'
PACKAGES = ('snowflake-snowpark-python', 'pypdf2')
HANDLER = 'pdf_text_chunker'
AS $$
from snowflake.snowpark.files import SnowflakeFile
import PyPDF2

class pdf_text_chunker:
    def process(self, file_url: str):
        with SnowflakeFile.open(file_url, 'rb') as f:
            pdf_reader = PyPDF2.PdfReader(f)
            text = ""
            for page in pdf_reader.pages:
                page_text = page.extract_text()
                if page_text:
                    text += page_text + "\n"
        
        # Simple chunking: ~1500 chars with 300 char overlap
        chunk_size = 1500
        overlap = 300
        chunks = []
        
        start = 0
        while start < len(text):
            end = start + chunk_size
            chunk = text[start:end]
            chunks.append(chunk)
            start = end - overlap
        
        for i, chunk in enumerate(chunks):
            yield (chunk, i)
$$;

-- Step 3: Load PDFs from stage into chunks table
-- Assumes PDFs are in @COLM_DB.UNSTRUCTURED.REPORTS stage
INSERT INTO DOCS_CHUNKS_TABLE (RELATIVE_PATH, SIZE, FILE_URL, SCOPED_FILE_URL, CHUNK, CHUNK_INDEX)
SELECT 
    relative_path,
    size,
    file_url,
    build_scoped_file_url(@REPORTS, relative_path) as scoped_file_url,
    c.chunk,
    c.chunk_index
FROM 
    DIRECTORY(@REPORTS) d,
    TABLE(PDF_TEXT_CHUNKER(build_scoped_file_url(@REPORTS, relative_path))) c
WHERE relative_path LIKE '%.pdf';

-- Step 4: Create RAG Q&A function using vector similarity search
CREATE OR REPLACE FUNCTION ASK_QUESTIONS_RAG(question VARCHAR)
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
SELECT SNOWFLAKE.CORTEX.COMPLETE(
    'claude-4-sonnet',
    CONCAT(
        'You are a financial analyst assistant. Answer the following question based on the provided context from company reports. ',
        'If the context does not contain relevant information, say so. Be precise and cite specific data when available.\n\n',
        'Context:\n',
        (SELECT LISTAGG(chunk, '\n\n---\n\n') WITHIN GROUP (ORDER BY sim DESC)
         FROM (
            SELECT chunk,
                   VECTOR_COSINE_SIMILARITY(
                       SNOWFLAKE.CORTEX.EMBED_TEXT_1024('voyage-multilingual-2', chunk)::VECTOR(FLOAT, 1024),
                       SNOWFLAKE.CORTEX.EMBED_TEXT_1024('voyage-multilingual-2', question)::VECTOR(FLOAT, 1024)
                   ) as sim
            FROM COLM_DB.UNSTRUCTURED.DOCS_CHUNKS_TABLE
            ORDER BY sim DESC
            LIMIT 5
        )),
        '\n\nQuestion: ', question,
        '\n\nAnswer:'
    )
)
$$;

-- Test the RAG function
SELECT ASK_QUESTIONS_RAG('What was NVIDIA revenue in 2025?');
