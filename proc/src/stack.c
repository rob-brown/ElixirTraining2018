#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define PUSH 1
#define POP 2
#define PEEK 3
#define CLEAR 4
#define COUNT 5
#define ITEM 6
#define ERROR 7
#define LOG 8

#define MAX_STACK 10
#define MAX_BUFFER 256

int stackLength = 0;
char * stack[MAX_STACK];

void sendError(const char * error) {
  int length = strlen(error);
  fprintf(stdout, "%c%c%s", ERROR, length, error);
  fflush(stdout);
}

void sendItem(const char * item) {
  int length = strlen(item);
  fprintf(stdout, "%c%c%s", ITEM, length, item);
  fflush(stdout);
}

void sendLog(const char * log) {
  int length = strlen(log);
  fprintf(stdout, "%c%c%s", LOG, length, log);
  fflush(stdout);
}

void handleTLV(char type, char length, char * buffer) {
  switch (type) {
    case PUSH: {
      char * item = (char *)calloc(length + 1, sizeof(char));
      memcpy(item, buffer, length);
      stack[stackLength] = item;
      stackLength++;
      break;
    }
    case POP: {
      char * item = stack[stackLength - 1];
      free(item);
      stackLength--;
      break;
    }
    case PEEK:
      if (stackLength == 0) {
        sendError("Stack full");
      }
      else {
        sendItem(stack[stackLength - 1]);
      }
      break;
    case COUNT: {
      char countBuffer[4];
      sprintf(countBuffer, "%d", stackLength);
      sendItem(countBuffer);
      break;
    }
    case CLEAR:
      stackLength = 0;
      break;
    default:
      break;
  }
}

int parseTLV(char * buffer, int bufferLength, int offset) {
  
  if (bufferLength - offset < 2) {
    return offset;
  }

  char type = buffer[0];
  char length = buffer[1];

  if (bufferLength - offset < length + 2) {
    return offset;
  }

  handleTLV(type, length, buffer);

  return parseTLV(buffer, bufferLength, offset + length + 2);
}

int main(int argc, char const * argv[]) {
  
  int bufferLength = 0;
  char buffer[MAX_BUFFER];

  sendLog("Starting");

  while(read(STDIN_FILENO, buffer + bufferLength, 1) > 0) {
    bufferLength++;

    sendLog("Received byte");

    int shift = parseTLV(buffer, bufferLength, 0);

    if (shift > 0) {
      sendLog("Shifting buffer");
      memmove(buffer + shift, buffer, bufferLength - shift);
      bufferLength -= shift;
    }
  }

  sendLog("Terminating");

  return 0;
}
