import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import utils 1.0

Control {
    id: root

    property string text
    property alias asset: identicon.asset
    property alias name: identicon.name
    property bool loading

    property Component customBackground: Component {
        Rectangle {
            border.width: 1
            border.color: Theme.palette.baseColor2
            color: enabled ? Theme.palette.baseColor4 : Theme.palette.baseColor3
            radius: 20
        }
    }

    QtObject {
        id: d
        property var loadingComponent: Component { LoadingComponent {} }
    }

    horizontalPadding: 12
    verticalPadding: Style.current.halfPadding
    spacing: 4

    background: Loader {
        sourceComponent: root.loading ? d.loadingComponent : root.customBackground
    }

    contentItem: RowLayout {
        spacing: root.spacing
        visible: !root.loading
        StatusSmartIdenticon {
            id: identicon
            Layout.preferredWidth: visible ? 16 : 0
            Layout.preferredHeight: visible ? 16 : 0
            asset.width: 16
            asset.height: 16
            asset.isImage: true
            visible: !!asset.source
        }
        StatusBaseText {
            Layout.fillWidth: true
            font.pixelSize: Style.current.tertiaryTextFontSize
            font.weight: Font.Medium
            text: root.text
            elide: Text.ElideRight
            color: enabled ? Theme.palette.directColor1 : Theme.palette.baseColor1
        }
    }
}
