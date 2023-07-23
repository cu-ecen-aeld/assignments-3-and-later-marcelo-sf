#include "threading.h"
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <pthread.h>

// Optional: use these functions to add debug or error prints to your application
#define DEBUG_LOG(msg,...)
//#define DEBUG_LOG(msg,...) printf("threading: " msg "\n" , ##__VA_ARGS__)
#define ERROR_LOG(msg,...) printf("threading ERROR: " msg "\n" , ##__VA_ARGS__)

int msleep(unsigned int duration_in_ms) {
  return usleep(duration_in_ms * 1000);
}

void* threadfunc(void* thread_param)
{

    // TODO: wait, obtain mutex, wait, release mutex as described by thread_data structure
    // hint: use a cast like the one below to obtain thread arguments from your parameter
    //struct thread_data* thread_func_args = (struct thread_data *) thread_param;
    int rc_lock,rc_unlock;
    struct thread_data* thread_func_args = (struct thread_data *) thread_param;

      printf("sleeping : %d ms before obtaining mutex lock\n",thread_func_args->wait_to_obtain_ms);
      msleep(thread_func_args->wait_to_obtain_ms);
      rc_lock = pthread_mutex_lock(thread_func_args->mutex);
      printf("rc_lock: %d\n",rc_lock);
      printf("sleeping : %d ms before releasing mutex lock\n",thread_func_args->wait_to_release_ms);
      msleep(thread_func_args->wait_to_release_ms);
      rc_unlock = pthread_mutex_unlock(thread_func_args->mutex);
      printf("rc_unlock: %d\n",rc_unlock);
      thread_func_args->thread_complete_success = true;
    return thread_param;
}


bool start_thread_obtaining_mutex(pthread_t *thread, pthread_mutex_t *mutex,int wait_to_obtain_ms, int wait_to_release_ms)
{
        /**
        * TODO: allocate memory for thread_data, setup mutex and wait arguments, pass thread_data to created thread
        * using threadfunc() as entry point.
        *
        * return true if successful.
        *
        * See implementation details in threading.h file comment block
        */
	//int lock_rc;
        struct thread_data* thread_func_args = (struct thread_data *) malloc(sizeof(struct thread_data));
	    thread_func_args->mutex = mutex;
	    thread_func_args->wait_to_obtain_ms = wait_to_obtain_ms;
	    thread_func_args->wait_to_release_ms = wait_to_release_ms;
	    printf("\nmutex init OK, starting thread with (%d,%d)\n", thread_func_args->wait_to_obtain_ms, thread_func_args->wait_to_release_ms);
            /*lock_rc = pthread_mutex_lock(&thread_func_args->mutex);
	    printf("\nmutex init after lock status: %d\n", lock_rc);
	    */
	    pthread_create(thread,NULL,threadfunc,thread_func_args);
	    return true;
}

