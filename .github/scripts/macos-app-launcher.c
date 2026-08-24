#include <errno.h>
#include <limits.h>
#include <mach-o/dyld.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static int remove_last_component(char *path)
{
	char *slash = strrchr(path, '/');

	if (!slash || slash == path) {
		return -1;
	}

	*slash = '\0';
	return 0;
}

int main(int argc, char **argv)
{
	char executable[PATH_MAX];
	char resolved[PATH_MAX];
	char game[PATH_MAX];
	char bundle_root[PATH_MAX];
	char data_dir[PATH_MAX];
	uint32_t executable_size = sizeof(executable);
	char **game_argv;
	int i;

	if (_NSGetExecutablePath(executable, &executable_size) != 0
			|| !realpath(executable, resolved)) {
		fprintf(stderr, "Could not locate the Perfect Dark application.\n");
		return 1;
	}

	if (snprintf(game, sizeof(game), "%s", resolved) >= (int)sizeof(game)
			|| remove_last_component(game) != 0
			|| strlcat(game, "/pd.arm64", sizeof(game)) >= sizeof(game)) {
		fprintf(stderr, "The Perfect Dark application path is too long.\n");
		return 1;
	}

	if (snprintf(bundle_root, sizeof(bundle_root), "%s", resolved) >= (int)sizeof(bundle_root)) {
		fprintf(stderr, "The Perfect Dark application path is too long.\n");
		return 1;
	}

	/* Launcher -> MacOS -> Contents -> Perfect Dark.app -> download folder. */
	for (i = 0; i < 4; ++i) {
		if (remove_last_component(bundle_root) != 0) {
			fprintf(stderr, "Could not locate the download folder.\n");
			return 1;
		}
	}

	if (snprintf(data_dir, sizeof(data_dir), "%s/data", bundle_root) >= (int)sizeof(data_dir)) {
		fprintf(stderr, "The Perfect Dark data path is too long.\n");
		return 1;
	}

#ifdef MACOS_LAUNCHER_TEST
	printf("%s\n", data_dir);
	return 0;
#endif

	game_argv = calloc((size_t)argc + 3, sizeof(*game_argv));
	if (!game_argv) {
		fprintf(stderr, "Could not prepare Perfect Dark: %s\n", strerror(errno));
		return 1;
	}

	game_argv[0] = game;
	game_argv[1] = "--basedir";
	game_argv[2] = data_dir;

	for (i = 1; i < argc; ++i) {
		game_argv[i + 2] = argv[i];
	}

	execv(game, game_argv);
	fprintf(stderr, "Could not start Perfect Dark: %s\n", strerror(errno));
	return 1;
}
