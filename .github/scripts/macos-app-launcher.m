#import <Cocoa/Cocoa.h>

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static void showError(NSString *message, NSString *details)
{
	NSAlert *alert = [[NSAlert alloc] init];
	alert.alertStyle = NSAlertStyleCritical;
	alert.messageText = message;
	alert.informativeText = details;
	[alert addButtonWithTitle:@"Quit"];
	[alert runModal];
}

static NSURL *getDataDirectory(void)
{
	NSArray<NSURL *> *urls = [[NSFileManager defaultManager]
		URLsForDirectory:NSApplicationSupportDirectory
		inDomains:NSUserDomainMask];
	NSURL *applicationSupport = urls.firstObject;
	NSURL *perfectDark = [applicationSupport URLByAppendingPathComponent:@"perfectdark" isDirectory:YES];
	return [perfectDark URLByAppendingPathComponent:@"data" isDirectory:YES];
}

static BOOL prepareDataDirectory(NSURL *dataDirectory)
{
	NSFileManager *files = [NSFileManager defaultManager];
	NSURL *textureDirectory = [dataDirectory URLByAppendingPathComponent:@"ext_tex" isDirectory:YES];
	NSError *error = nil;

	if (![files createDirectoryAtURL:textureDirectory
			withIntermediateDirectories:YES
			attributes:nil
			error:&error]) {
		showError(@"Could Not Create the Perfect Dark Data Folder", error.localizedDescription);
		return NO;
	}

	return YES;
}

static BOOL installRomIfNeeded(NSURL *dataDirectory)
{
	NSFileManager *files = [NSFileManager defaultManager];
	NSURL *romDestination = [dataDirectory URLByAppendingPathComponent:@"pd.ntsc-final.z64"];

	if ([files fileExistsAtPath:romDestination.path]) {
		return YES;
	}

	NSAlert *alert = [[NSAlert alloc] init];
	alert.messageText = @"Perfect Dark ROM Required";
	alert.informativeText = @"Choose your legally obtained NTSC Final Perfect Dark ROM. It will be copied into Perfect Dark's data folder and named pd.ntsc-final.z64.";
	[alert addButtonWithTitle:@"Choose ROM…"];
	[alert addButtonWithTitle:@"Quit"];

	if ([alert runModal] != NSAlertFirstButtonReturn) {
		return NO;
	}

	NSOpenPanel *panel = [NSOpenPanel openPanel];
	panel.canChooseFiles = YES;
	panel.canChooseDirectories = NO;
	panel.allowsMultipleSelection = NO;
	panel.allowedFileTypes = @[@"z64"];
	panel.prompt = @"Choose ROM";
	panel.message = @"Select your NTSC Final Perfect Dark ROM.";

	if ([panel runModal] != NSModalResponseOK) {
		return NO;
	}

	NSError *error = nil;
	if (![files copyItemAtURL:panel.URL toURL:romDestination error:&error]) {
		showError(@"Could Not Install the Perfect Dark ROM", error.localizedDescription);
		return NO;
	}

	NSAlert *installed = [[NSAlert alloc] init];
	installed.messageText = @"Perfect Dark ROM Installed";
	installed.informativeText = @"Optional texture packs go in the ext_tex folder inside Perfect Dark's data folder.";
	[installed addButtonWithTitle:@"Start Perfect Dark"];
	[installed addButtonWithTitle:@"Open Data Folder and Quit"];

	if ([installed runModal] == NSAlertSecondButtonReturn) {
		[[NSWorkspace sharedWorkspace] openURL:dataDirectory];
		return NO;
	}

	return YES;
}

int main(int argc, char **argv)
{
	@autoreleasepool {
		[NSApplication sharedApplication];
		[NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
		[NSApp activateIgnoringOtherApps:YES];

		NSURL *dataDirectory = getDataDirectory();

#ifdef MACOS_LAUNCHER_TEST
		printf("%s\n", dataDirectory.fileSystemRepresentation);
		return 0;
#endif

		if (!prepareDataDirectory(dataDirectory) || !installRomIfNeeded(dataDirectory)) {
			return 0;
		}

		NSString *gamePath = [[NSBundle mainBundle].bundlePath
			stringByAppendingPathComponent:@"Contents/MacOS/pd.arm64"];
		const char *game = gamePath.fileSystemRepresentation;
		const char *data = dataDirectory.fileSystemRepresentation;
		char **gameArgv = calloc((size_t)argc + 3, sizeof(*gameArgv));

		if (!gameArgv) {
			showError(@"Could Not Start Perfect Dark",
				[NSString stringWithUTF8String:strerror(errno)]);
			return 1;
		}

		gameArgv[0] = (char *)game;
		gameArgv[1] = "--basedir";
		gameArgv[2] = (char *)data;

		for (int i = 1; i < argc; ++i) {
			gameArgv[i + 2] = argv[i];
		}

		execv(game, gameArgv);
		showError(@"Could Not Start Perfect Dark",
			[NSString stringWithUTF8String:strerror(errno)]);
		return 1;
	}
}
