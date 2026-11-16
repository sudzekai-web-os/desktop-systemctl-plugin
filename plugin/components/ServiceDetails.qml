import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import linctrl
import "../SystemctlPresentation.js" as Display

AppCard {
    id: root
    property var service: null
    property bool busy: false
    readonly property bool canManage: AccountSession.administrator && !!service?.canManage
    readonly property bool autostart: service?.unitFileState === "enabled"
    signal operation(string verb)
    signal editRequested()
    signal targetsRequested()
    signal restartPolicyRequested(bool enabled)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            AppText {
                Layout.fillWidth: true
                font.bold: true
                textFormat: Text.PlainText
                elide: Text.ElideRight
                text: root.service?.name || "Выберите службу"
            }
            AppIconButton {
                visible: root.service !== null
                glyph: Qt.resolvedUrl("../icons/play-fill.svg")
                caption: "Запустить"
                enabled: !root.busy
                onClicked: root.operation("start")
            }
            AppIconButton {
                visible: root.service !== null
                glyph: Qt.resolvedUrl("../icons/stop-fill.svg")
                caption: "Остановить"
                enabled: !root.busy
                onClicked: root.operation("stop")
            }
            AppIconButton {
                visible: root.service !== null
                glyph: Qt.resolvedUrl("../icons/arrow-clockwise.svg")
                caption: "Перезапустить"
                enabled: !root.busy
                onClicked: root.operation("restart")
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.service !== null
            contentWidth: availableWidth
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 9
                AppText {
                    Layout.fillWidth: true
                    visible: !root.canManage
                    wrapMode: Text.Wrap
                    text: AccountSession.administrator
                        ? "Управление этой службой ограничено настройкой Systemctl:AllowedUnits на сервере."
                        : "Для управления службой требуется роль администратора."
                }
                ServiceField { label: "Описание"; value: root.service?.description || "—" }
                ServiceField { label: "Состояние"; value: Display.state(root.service?.activeState) }
                ServiceField { label: "Подсостояние"; value: root.service?.subState || "—" }
                ServiceField { label: "Загрузка"; value: Display.state(root.service?.loadState) }
                RowLayout {
                    Layout.fillWidth: true
                    ServiceField { label: "Автозапуск"; value: Display.state(root.service?.unitFileState) }
                    AppIconButton {
                        glyph: Qt.resolvedUrl(root.autostart ? "../icons/toggle-on.svg" : "../icons/toggle-off.svg")
                        caption: root.autostart ? "Выключить автозапуск" : "Включить автозапуск"
                        enabled: !root.busy
                        onClicked: root.operation(root.autostart ? "disable" : "enable")
                    }
                }
                ServiceField { label: "Авторестарт"; value: root.service?.restartPolicy || "—" }
                ServiceField { label: "Targets"; value: (root.service?.targets || []).join("\n") || "—" }
                Flow {
                    Layout.fillWidth: true
                    spacing: 6
                    visible: AccountSession.administrator && !!root.service?.canManage

                    DefaultButton {
                        text: root.service?.restartPolicy && root.service.restartPolicy !== "no"
                            ? "Выключить авторестарт" : "Включить авторестарт"
                        enabled: !root.busy
                        onClicked: root.restartPolicyRequested(!root.service?.restartPolicy || root.service.restartPolicy === "no")
                    }
                    DefaultButton {
                        text: "Добавить target"
                        enabled: !root.busy
                        onClicked: root.targetsRequested()
                    }
                    DefaultButton {
                        visible: !!root.service?.canEdit
                        text: "Редактировать файл"
                        enabled: !root.busy
                        onClicked: root.editRequested()
                    }
                    DefaultButton {
                        visible: !!root.service?.canEdit
                        text: "Удалить"
                        enabled: !root.busy
                        onClicked: root.operation("delete")
                    }
                }
            }
        }
        Item { Layout.fillHeight: true; visible: root.service === null }
    }
}
