import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

DropArea {
    id: root
    objectName: "manageTokensGroupDelegate-%1".arg(index)

    // expected roles: communityId, communityName, communityImage, collectionUid, collectionName, imageUrl // FIXME unify group image

    property int visualIndex: index
    property var controller
    property var dragParent
    property alias dragEnabled: groupedCommunityTokenDelegate.dragEnabled
    property bool isCollectible: isCollection
    property bool isCollection
    property bool isHidden // inside the "Hidden" section

    readonly property string groupId: isCollection ? model.collectionUid : model.communityId
    readonly property int childCount: model.enabledNetworkBalance // NB using "balance" as "count" in the grouped model
    readonly property alias title: groupedCommunityTokenDelegate.title

    ListView.onRemove: SequentialAnimation {
        PropertyAction { target: root; property: "ListView.delayRemove"; value: true }
        NumberAnimation { target: root; property: "scale"; to: 0; easing.type: Easing.InOutQuad }
        PropertyAction { target: root; property: "ListView.delayRemove"; value: false }
    }

    keys: isCollection ? ["x-status-draggable-collection-group-item"] : ["x-status-draggable-community-group-item"]
    width: ListView.view ? ListView.view.width : 0
    height: groupedCommunityTokenDelegate.implicitHeight

    onEntered: function(drag) {
        const from = drag.source.visualIndex
        const to = groupedCommunityTokenDelegate.visualIndex
        if (to === from)
            return
        ListView.view.model.moveItem(from, to)
        drag.accept()
    }

    StatusDraggableListItem {
        id: groupedCommunityTokenDelegate
        width: parent.width
        height: dragActive ? implicitHeight : parent.height
        draggable: true
        spacing: 12
        bgColor: Theme.palette.baseColor4
        title: root.isCollection ? model.collectionName : model.communityName

        visualIndex: index
        dragParent: root.dragParent
        Drag.keys: root.keys
        Drag.hotSpot.x: root.width/2
        Drag.hotSpot.y: root.height/2

        contentItem: RowLayout {
            spacing: groupedCommunityTokenDelegate.spacing

            StatusIcon {
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                icon: "justify"
                color: root.dragEnabled ? Theme.palette.baseColor1 : Theme.palette.baseColor2
            }

            StatusRoundedImage {
                radius: root.isCollection ? Style.current.radius : height/2
                Layout.preferredWidth: root.isCollectible ? 44 : 32
                Layout.preferredHeight: root.isCollectible ? 44 : 32
                image.source: root.isCollection ? model.imageUrl : model.communityImage // FIXME unify group image
                showLoadingIndicator: true
                image.fillMode: Image.PreserveAspectCrop
            }

            StatusBaseText {
                Layout.fillWidth: true
                text: groupedCommunityTokenDelegate.title
                elide: Text.ElideRight
                maximumLineCount: 1
                font.weight: Font.Medium
            }

            Item { Layout.fillWidth: true }

            ManageTokensCommunityTag {
                text: root.childCount
                asset.name: root.isCollectible ? "image" : "token"
                asset.isImage: false
                asset.color: Theme.palette.baseColor1
                enabled: false
            }

            ManageTokenMenuButton {
                objectName: "btnManageTokenMenu-%1".arg(currentIndex)
                currentIndex: visualIndex
                count: root.isCollection ? root.controller.collectionGroupsModel.count :
                                           root.controller.communityTokenGroupsModel.count
                isGroup: true
                isCollection: root.isCollection
                isCollectible: root.isCollectible
                groupId: root.groupId
                inHidden: root.isHidden
                onMoveRequested: (from, to) => root.ListView.view.model.moveItem(from, to)
                onShowHideGroupRequested: function(groupId, flag) {
                    if (root.isCollection)
                        root.controller.showHideCollectionGroup(groupId, flag)
                    else
                        root.controller.showHideGroup(groupId, flag)
                }
            }
        }
    }
}
