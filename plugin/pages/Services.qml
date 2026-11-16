import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import linctrl
import "../api"
import "../components"
import "../SystemctlPresentation.js" as Display

ColumnLayout {
    id: root
    property var services: []
    property var details: null
    property string selected: ""
    property var targetNames: []
    property string target: ""
    readonly property var entries: services.filter(service => (service.name + " " + service.description)
        .toLowerCase().includes(search.text.trim().toLowerCase()))

    SystemctlClient { id: request }

    function load() {
        request.list(target, data => {
            services = data || []
            if (selected && services.some(service => service.name === selected))
                inspect(selected)
            else {
                selected = ""
                details = null
            }
        })
    }

    function inspect(name) {
        if (selected !== name)
            details = null
        selected = name
        request.inspect(name, data => details = data)
    }

    Component.onCompleted: {
        load()
        targetRequest.targets(data => targetNames = data || [])
    }

    SystemctlClient { id: targetRequest }

    RowLayout {
        Layout.fillWidth: true
        AppIconButton {
            glyph: Qt.resolvedUrl("../icons/arrow-clockwise.svg")
            caption: "Обновить службы"
            enabled: !request.busy
            onClicked: root.load()
        }
        DefaultButton {
            visible: AccountSession.administrator
            text: "Создать службу"
            enabled: !request.busy
            onClicked: {
                request.error = ""
                editor.start("", "[Unit]\nDescription=\n\n[Service]\nExecStart=\n\n[Install]\nWantedBy=multi-user.target\n")
            }
        }
        AppComboBox {
            id: targetFilter
            Layout.preferredWidth: 220
            enabled: !request.busy && root.targetNames.length > 0
            model: ["Все targets"].concat(root.targetNames)
            onActivated: index => {
                root.target = index > 0 ? root.targetNames[index - 1] : ""
                root.load()
            }
        }

        AppField {
            id: search
            Layout.fillWidth: true
            placeholderText: "Поиск службы"
        }
    }

    AppText {
        Layout.fillWidth: true
        visible: request.error !== ""
        text: request.error
        textFormat: Text.PlainText
        color: Theme.palette.accent
    }

    ResizableSplit {
        id: split
        Layout.fillWidth: true
        Layout.fillHeight: true

        AppCard {
            SplitView.fillWidth: true
            ListView {
                anchors.fill: parent
                anchors.margins: 8
                model: root.entries
                spacing: 4
                clip: true
                delegate: DefaultButton {
                    id: row
                    required property var modelData
                    width: ListView.view.width
                    selected: root.selected === modelData.name
                    enabled: !request.busy
                    onClicked: root.inspect(modelData.name)

                    contentItem: RowLayout {
                        AppText {
                            Layout.fillWidth: true
                            text: row.modelData.name
                            textFormat: Text.PlainText
                            elide: Text.ElideRight
                        }
                        AppText { text: Display.state(row.modelData.activeState); color: Theme.palette.muted }
                    }
                }
                ScrollBar.vertical: ScrollBar {}
            }
            AppText {
                anchors.centerIn: parent
                visible: root.entries.length === 0
                text: request.busy ? "Загрузка…" : "Службы не найдены"
            }
        }

        ServiceDetails {
            SplitView.minimumWidth: split.minimumPanelWidth
            SplitView.maximumWidth: split.maximumPanelWidth
            SplitView.preferredWidth: Math.max(split.minimumPanelWidth, Math.floor(split.width * 0.42))
            service: root.details
            busy: request.busy
            onEditRequested: request.readFile(root.selected, data => editor.start(root.selected, data))
            onTargetsRequested: request.targets(data => targetPicker.start(data || [], root.details?.targets || []))
            onRestartPolicyRequested: enabled => request.restartPolicy(root.selected, enabled, data => root.details = data)
            onOperation: verb => {
                if (verb === "delete") {
                    confirmation.name = root.selected
                    confirmation.open()
                    return
                }

                request.change(root.selected, verb, data => {
                    root.details = data
                    root.services = root.services.map(service => service.name === data.name ? data : service)
                })
            }
        }
    }

    AppDialog {
        id: confirmation
        property string name: ""
        title: "Удаление службы"
        acceptText: "Удалить"
        cancelText: "Отмена"
        description: "Служба будет остановлена, а её файл удалён: " + name
        onAccepted: request.remove(name, () => root.load())
    }

    UnitFileEditor {
        id: editor
        busy: request.busy
        serverError: request.error
        onSubmitted: (name, content, creating) => request.saveFile(name, content, creating, data => {
            root.selected = data.name
            close()
            root.load()
        })
    }

    TargetPicker {
        id: targetPicker
        busy: request.busy
        serverError: request.error
        onSubmitted: target => request.addTarget(root.selected, target, data => {
            root.details = data
            close()
        })
    }
}
