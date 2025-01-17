import QtQuick 2.13
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.13

import utils 1.0
import shared.popups 1.0

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

FocusScope {
    id: root

    property string sectionTitle
    property int contentWidth
    readonly property int contentHeight: root.height - titleRow.height - Style.current.padding

    property alias titleRowLeftComponentLoader: leftLoader
    property alias titleRowComponentLoader: loader
    property list<Item> headerComponents
    property alias bottomHeaderComponents: secondHeaderRow.contentItem
    default property alias content: contentWrapper.children
    property alias titleLayout: titleLayout

    property bool dirty: false
    property bool ignoreDirty // ignore dirty state and do not notifyDirty()
    property bool saveChangesButtonEnabled: false
    readonly property alias toast: settingsDirtyToastMessage

    readonly property real availableHeight:
        scrollView.availableHeight - settingsDirtyToastMessagePlaceholder.height
        - Style.current.bigPadding

    signal baseAreaClicked()
    signal saveChangesClicked()
    signal saveForLaterClicked()
    signal resetChangesClicked()

    function notifyDirty() {
        settingsDirtyToastMessage.notifyDirty();
    }

    QtObject {
        id: d

        readonly property int titleRowHeight: 56
    }

    MouseArea {
        anchors.fill: parent
        onClicked: { root.baseAreaClicked() }
    }

    Component.onCompleted: {
        if (headerComponents.length) {
            for (let i in headerComponents) {
                headerComponents[i].parent = titleRow
            }
        }
    }

    ColumnLayout {
        id: titleRow
        width: root.contentWidth
        spacing: 0

        RowLayout {
            id: titleLayout
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? d.titleRowHeight : 0
            visible: (root.sectionTitle !== "")

            Loader {
                id: leftLoader
            }

            StatusBaseText {
                Layout.fillWidth: true
                text: root.sectionTitle
                font.weight: Font.Bold
                font.pixelSize: Constants.settingsSection.mainHeaderFontSize
                color: Theme.palette.directColor1
            }

            Loader {
                id: loader
            }
        }
        Control {
            id: secondHeaderRow
            Layout.fillWidth: true
            visible: !!contentItem
        }
    }

    StatusScrollView {
        id: scrollView
        objectName: "settingsContentBaseScrollView"
        anchors.top: titleRow.bottom
        anchors.bottom: parent.bottom
        anchors.topMargin: titleLayout.visible ? Style.current.padding: 0
        padding: 0
        width: root.width
        contentWidth: root.contentWidth
        contentHeight: contentLayout.implicitHeight + Style.current.bigPadding

        Column {
            id: contentLayout
            width: scrollView.availableWidth

            MouseArea {
                onClicked: root.baseAreaClicked()
                width: contentWrapper.implicitWidth
                height: contentWrapper.implicitHeight
                hoverEnabled: true

                Column {
                    id: contentWrapper
                    onVisibleChanged: if (visible) forceActiveFocus()
                }
            }

            Item {
                id: settingsDirtyToastMessagePlaceholder

                width: settingsDirtyToastMessage.implicitWidth
                height: settingsDirtyToastMessage.active && !root.ignoreDirty ? settingsDirtyToastMessage.implicitHeight : 0

                Behavior on implicitHeight {
                    enabled: !root.ignoreDirty
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
    }

    SettingsDirtyToastMessage {
        id: settingsDirtyToastMessage
        anchors.bottom: scrollView.bottom
        anchors.bottomMargin: root.ignoreDirty ? 40 : 0
        anchors.horizontalCenter: scrollView.horizontalCenter
        active: root.dirty
        flickable: root.ignoreDirty ? null : scrollView.flickable
        saveChangesButtonEnabled: root.saveChangesButtonEnabled
        onResetChangesClicked: root.resetChangesClicked()
        onSaveChangesClicked: root.saveChangesClicked()
        onSaveForLaterClicked: root.saveForLaterClicked()
    }
}
