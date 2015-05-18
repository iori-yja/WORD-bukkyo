#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int
main(void)
{
	char input[3];
	char buf[17];
	char c;


	for (int i = 0; i < 16; i++) {
		fgets(input, 3, stdin);
		c = 0;
		c = (char) strtol(input, NULL, 16);
		buf[i] = c;
		if (c == 0) break;
	}
	buf[16] = 0;
	puts(buf);

	return 0;

}

