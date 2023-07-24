#include <stdio.h>
#include <stdlib.h>
#include <libgen.h>
#include <syslog.h>
#include <errno.h>
#include <string.h>

int main(int argc, char*argv[]) {
	char* file_path = argv[1];
	const char* text = argv[2];
	FILE* file_handler=NULL;
	size_t write_status;

	setlogmask (LOG_UPTO (LOG_NOTICE));
	openlog ("writer", LOG_CONS | LOG_PID | LOG_NDELAY, LOG_LOCAL1);


	syslog(LOG_ERR,"%s Starting",argv[0]);

	if (argc < 3) {
		syslog(LOG_ERR,"missing arguments writefile writestr\n");
		exit(1);
	}

	file_handler = fopen(file_path,"a+");
	if(NULL == file_handler) {
		perror("writer");
		syslog(LOG_ERR,"Could not open file %s for read/write/append",file_path);
		exit(1);
	}
	syslog(LOG_DEBUG,"Writing %s to %s",text,file_path);
	write_status = fprintf(file_handler,"%s",text);
	if(write_status < 0) {
		perror("write error in printf");
		syslog(LOG_ERR,"In file %s, error: %s",file_path, strerror(errno));
		exit(1);
	}
	fclose(file_handler);
	closelog();
	
}
