import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as CoreUtils
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import shared.views.chat 1.0
import utils 1.0

ActivityNotificationBase {
    id: root

    readonly property bool isOutgoingRequest: notification && notification.message.amISender
    readonly property string contactId: notification ? isOutgoingRequest ? notification.chatId : notification.author : ""

    property var contactDetails: null
    property int maximumLineCount: 2

    signal messageClicked()

    property StatusMessageDetails messageDetails: StatusMessageDetails {
        messageText: notification ? notification.message.messageText : ""
        amISender: false
        sender.id: contactId
        sender.displayName: contactDetails ? contactDetails.displayName : ""
        sender.secondaryName: contactDetails ? contactDetails.localNickname : ""
        sender.trustIndicator: contactDetails ? contactDetails.trustStatus : Constants.trustStatus.unknown
        sender.profileImage {
            width: 40
            height: 40
            name: contactDetails ? contactDetails.displayIcon : ""
            assetSettings.isImage: contactDetails && contactDetails.displayIcon.startsWith("data")
            pubkey: contactId
            colorId: Utils.colorIdForPubkey(contactId)
            colorHash: Utils.getColorHashAsJson(contactId, contactDetails && contactDetails.ensVerified)
        }
    }

    property Component messageSubheaderComponent: null
    property Component messageBadgeComponent: null

    function openProfilePopup() {
        closeActivityCenter()
        Global.openProfilePopup(contactId)
    }

    function updateContactDetails() {
        contactDetails = notification ? Utils.getContactDetailsAsJson(contactId, false) : null
    }

    onContactIdChanged: root.updateContactDetails()

    Connections {
        target: root.store.contactsStore.myContactsModel

        function onItemChanged(pubKey) {
            if (pubKey === root.contactId)
                root.updateContactDetails()
        }
    }

    bodyComponent: MouseArea {
        height: messageView.implicitHeight
        hoverEnabled: root.messageBadgeComponent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.activityCenterStore.switchTo(notification)
            root.closeActivityCenter()
        }

        SimplifiedMessageView {
            id: messageView
            width: parent.width
            maximumLineCount: root.maximumLineCount
            messageDetails: root.messageDetails
            timestamp: notification ? notification.timestamp : ""
            messageSubheaderComponent: root.messageSubheaderComponent
            messageBadgeComponent: root.messageBadgeComponent
            onOpenProfilePopup: root.openProfilePopup()
        }
    }
}
