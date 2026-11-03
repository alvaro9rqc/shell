pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Caelestia
import Caelestia.I18n

Singleton {
    id: root

    property bool active: false

    function toggle(): void {
        if (root.active)
            root.disable();
        else
            root.enable();
    }

    function enable(): void {
        if (root.active)
            return;

        root.active = true;
        inhibitProc.running = true;
        Toaster.toast(
            Tr.tr("Server mode enabled"),
            Tr.tr("Suspension on lid close is disabled"),
            "dns"
        );
    }

    function disable(): void {
        if (!root.active)
            return;

        root.active = false;
        inhibitProc.running = false;
        Toaster.toast(
            Tr.tr("Server mode disabled"),
            Tr.tr("Normal power management restored"),
            "dns"
        );
    }

    Process {
        id: inhibitProc

        command: [
            "systemd-inhibit",
            "--what=handle-lid-switch:idle:sleep",
            "--who=Caelestia Server Mode",
            "--why=Server Mode active",
            "sleep",
            "infinity"
        ]

        onExited: (code, status) => {
            if (root.active) {
                root.active = false;
            }
        }
    }

    IpcHandler {
        target: "serverMode"

        function isEnabled(): bool {
            return root.active;
        }

        function toggle(): void {
            root.toggle();
        }

        function enable(): void {
            root.enable();
        }

        function disable(): void {
            root.disable();
        }
    }
}
