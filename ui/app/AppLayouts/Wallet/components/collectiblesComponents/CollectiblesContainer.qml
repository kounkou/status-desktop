import QtQuick 2.13
import QtGraphicalEffects 1.13
import "../../../../../imports"
import "../../../../../shared"

Item {
    property url collectibleIconSource: "../../../../img/collectibles/CryptoKitties.png"
    property string collectibleName: "CryptoKitties"
    property bool isLoading: true
    property bool collectiblesOpened: false
    property var collectiblesModal
    property string buttonText: "View in Cryptokitties"
    property var getLink: function () {}

    id: root

    CollectiblesHeader {
        id: collectiblesHeader
        collectibleName: root.collectibleName
        collectibleIconSource: root.collectibleIconSource
        isLoading: root.isLoading
        toggleCollectible: function () {
            root.collectiblesOpened = !root.collectiblesOpened
        }
    }

    Loader {
        active: root.collectiblesOpened
        sourceComponent: contentComponent
        anchors.top: collectiblesHeader.bottom
        anchors.topMargin: Style.current.halfPadding
        width: parent.width
    }

    Component {
        id: contentComponent

        CollectiblesContent {
            collectiblesModal: root.collectiblesModal
            buttonText: root.buttonText
            getLink: root.getLink
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
