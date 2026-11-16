import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import linctrl

AppDialog {
    id: root
    title: "Добавление в target"
    property var targets: []
    property var assigned: []
    property string selected: ""
    property string serverError: ""
    signal submitted(string target)

    function start(items, current) {
        targets = items
        assigned = current
        selected = ""
        filter.text = ""
        open()
    }

    contentItem: ColumnLayout {
        AppField {
            id: filter
            Layout.fillWidth: true
            placeholderText: "Поиск target"
            onTextChanged: root.selected = ""
        }
        ListView {
            Layout.fillWidth: true
            Layout.preferredHeight: 235
            clip: true
            spacing: 4
            model: root.targets.filter(target => target.includes(filter.text.trim().toLowerCase()))
            delegate: DefaultButton {
                required property string modelData
                width: ListView.view.width
                text: modelData
                selected: root.selected === modelData
                enabled: !root.busy && !root.assigned.includes(modelData)
                onClicked: root.selected = modelData
            }
            ScrollBar.vertical: ScrollBar {}
            AppText { anchors.centerIn: parent; visible: parent.count === 0; text: "Targets не найдены" }
        }
        AppText {
            Layout.fillWidth: true
            visible: text !== ""
            text: root.serverError
            color: Theme.palette.accent
            wrapMode: Text.Wrap
        }
        RowLayout {
            Layout.alignment: Qt.AlignRight
            DefaultButton { text: "Отмена"; enabled: !root.busy; onClicked: root.close() }
            DefaultButton {
                text: "Добавить"
                primary: true
                enabled: !root.busy && root.selected !== ""
                onClicked: root.submitted(root.selected)
            }
        }
    }
}
