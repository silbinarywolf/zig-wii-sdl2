// Export all SDL_* functions, etc
pub usingnamespace @cImport({
    // @cUndef("__linux__"); // note(jae): experiment with os_tag == .linux so std functions "just work"
    @cInclude("SDL.h");
});

// Get various native Wii functions to initialize SDL
const c = @cImport({
    @cInclude("fat.h");
    @cInclude("gccore.h");
    @cInclude("ogc/usbmouse.h");
    @cInclude("ogcsys.h");
    @cInclude("wiikeyboard/keyboard.h");
    @cInclude("wiiuse/wpad.h");

    // OGC_PowerOffRequested / OGC_ResetRequested
    @cInclude("video/ogc/SDL_ogcevents_c.h");
});

fn PowerShutdownCB(_: i32) callconv(.C) void {
    ShutdownCB();
}

fn ShutdownCB() callconv(.C) void {
    c.OGC_PowerOffRequested = true;
}

fn ResetCB(_: u32, _: ?*anyopaque) callconv(.C) void {
    c.OGC_ResetRequested = true;
}

/// Wii_SDL_Init matches the functionality of libSDLmain.a before it calls SDL_main
///
/// https://github.com/devkitPro/SDL/blob/8378cba5eeb77d6c53fce940192c9c00772cfe80/src/main/wii/SDL_wii_main.c
pub fn Wii_SDL_Init() !void {
    c.L2Enhance();
    const version = c.IOS_GetVersion();
    const preferred = c.IOS_GetPreferredVersion();
    if (preferred > 0 and version != preferred) {
        if (c.IOS_ReloadIOS(preferred) != 0) {
            return error.IOSReloadFailed;
        }
    }
    if (c.WPAD_Init() != 0) {
        return error.WpadInitFailed;
    }
    // NOTE(jae): 2024-06-05
    // Causes Dolphin to lock up and crash
    // c.WPAD_SetPowerButtonCallback(PowerShutdownCB);
    // _ = c.SYS_SetPowerCallback(ShutdownCB);
    // _ = c.SYS_SetResetCallback(ResetCB);

    // TODO OGC_InitVideoSystem();
    // Source: https://github.com/devkitPro/SDL/blob/8378cba5eeb77d6c53fce940192c9c00772cfe80/src/main/wii/SDL_wii_main.c#L71
    if (c.WPAD_SetDataFormat(c.WPAD_CHAN_ALL, c.WPAD_FMT_BTNS_ACC_IR) != 0) {
        return error.WpadSetDataFormatFailed;
    }
    if (c.WPAD_SetVRes(c.WPAD_CHAN_ALL, 640, 480) != 0) {
        return error.WPADSetVResFailed;
    }
    if (c.MOUSE_Init() != 0) {
        return error.MouseInitFailed;
    }
    if (c.KEYBOARD_Init(null) != 0) {
        return error.KeyboardInitFailed;
    }
    if (!c.fatInitDefault()) {
        return error.FatInitFailed;
    }
}
