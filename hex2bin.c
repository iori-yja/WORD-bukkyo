#include <stdio.h>
#include <stdlib.h>
#include <strings.h>

int
main(void)
{
	char input[3];
	char buf[17];
	char c;

	bzero(buf, 17);
	for (int i = 0; i < 16; i++) {
		fgets(input, 3, stdin);
		c = (char) strtol(input, NULL, 16);
		buf[i] = c;
		if (c == 0) break;
	}
	buf[16] = 0;
	puts(buf);

	return 0;

}

