import QtQuick
import QtQuick.Layouts
import linctrl

ColumnLayout {
    required property string label
    required property string value
    Layout.fillWidth: true
    spacing: 2

    AppText { text: parent.label; color: Theme.palette.muted }
    AppText { Layout.fillWidth: true; text: parent.value; textFormat: Text.PlainText; wrapMode: Text.Wrap }
}
