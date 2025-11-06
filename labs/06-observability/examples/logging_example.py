# Custom Application Logging Example
import logging
import json
from datetime import datetime
import uuid

class JsonFormatter(logging.Formatter):
    def format(self, record):
        log_record = {
            'timestamp': datetime.utcnow().isoformat(),
            'level': record.levelname,
            'service': 'user-service',
            'trace_id': getattr(record, 'trace_id', str(uuid.uuid4())),
            'message': record.getMessage(),
            'logger': record.name
        }
        
        if record.exc_info:
            log_record['exception'] = self.formatException(record.exc_info)
            
        return json.dumps(log_record)

def setup_logging():
    logger = logging.getLogger('application')
    handler = logging.FileHandler('application.log')
    handler.setFormatter(JsonFormatter())
    logger.addHandler(handler)
    logger.setLevel(logging.INFO)
    return logger

def main():
    logger = setup_logging()
    
    # Example usage
    try:
        # Simulate normal operation
        logger.info('Processing user request', extra={'trace_id': str(uuid.uuid4())})
        
        # Simulate error
        raise ValueError('Invalid user input')
    except Exception as e:
        logger.error('Error processing request', 
                    extra={'trace_id': str(uuid.uuid4())},
                    exc_info=True)

if __name__ == '__main__':
    main()