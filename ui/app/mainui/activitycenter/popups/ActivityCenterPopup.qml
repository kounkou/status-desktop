import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import shared 1.0
import shared.popups 1.0
import shared.views.chat 1.0

import utils 1.0

import "../views"
import "../panels"
import "../stores"

Popup {
    id: root

    property ActivityCenterStore activityCenterStore
    property var store

    onOpened: {
        Global.activityPopupOpened = true
    }
    onClosed: {
        Global.activityPopupOpened = false
        Qt.callLater(activityCenterStore.markAsSeenActivityCenterNotifications)
    }

    width: 560
    padding: 0
    modal: true
    parent: Overlay.overlay

    QtObject {
        id: d

        readonly property var loadMoreNotificationsIfScrollBelowThreshold: Backpressure.oneInTimeQueued(root, 100, function() {
            if (listView.contentY >= listView.contentHeight - listView.height - 1) {
                root.activityCenterStore.fetchActivityCenterNotifications()
            }
        })
    }

    Overlay.modal: MouseArea { // eat every event behind the popup
        hoverEnabled: true
        onPressed: (event) => {
                       event.accept()
                       root.close()
                   }
        onWheel: (event) => event.accept()
    }

    background: Rectangle {
        color: Style.current.background
        radius: Style.current.radius
        layer.enabled: true
        layer.effect: DropShadow {
            verticalOffset: 3
            radius: Style.current.radius
            samples: 15
            fast: true
            cached: true
            color: Style.current.dropShadow
        }
    }

    ActivityCenterPopupTopBarPanel {
        id: activityCenterTopBar
        width: parent.width
        unreadNotificationsCount: activityCenterStore.unreadNotificationsCount
        hasAdmin: activityCenterStore.adminCount > 0
        hasReplies: activityCenterStore.repliesCount > 0
        hasMentions: activityCenterStore.mentionsCount > 0
        hasContactRequests: activityCenterStore.contactRequestsCount > 0
        hasIdentityVerification: activityCenterStore.identityVerificationCount > 0
        hasMembership: activityCenterStore.membershipCount > 0
        hideReadNotifications: activityCenterStore.activityCenterReadType === ActivityCenterStore.ActivityCenterReadType.Unread
        activeGroup: activityCenterStore.activeNotificationGroup
        onGroupTriggered: activityCenterStore.setActiveNotificationGroup(group)
        onMarkAllReadClicked: activityCenterStore.markAllActivityCenterNotificationsRead()
        onShowHideReadNotifications: activityCenterStore.setActivityCenterReadType(hideReadNotifications ?
                                                                                       ActivityCenterStore.ActivityCenterReadType.Unread :
                                                                                       ActivityCenterStore.ActivityCenterReadType.All)
    }

    StatusListView {
        id: listView

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: activityCenterTopBar.bottom
        anchors.bottom: parent.bottom
        anchors.margins: Style.current.smallPadding
        spacing: 1

        model: root.activityCenterStore.activityCenterNotifications

        onContentYChanged: d.loadMoreNotificationsIfScrollBelowThreshold()

        delegate: Loader {
            width: listView.availableWidth

            property int filteredIndex: index
            property var notification: model

            sourceComponent: {
                switch (model.notificationType) {
                case ActivityCenterStore.ActivityCenterNotificationType.Mention:
                    return mentionNotificationComponent
                case ActivityCenterStore.ActivityCenterNotificationType.Reply:
                    return replyNotificationComponent
                case ActivityCenterStore.ActivityCenterNotificationType.ContactRequest:
                    return contactRequestNotificationComponent
                case ActivityCenterStore.ActivityCenterNotificationType.ContactVerification:
                    return verificationRequestNotificationComponent
                case ActivityCenterStore.ActivityCenterNotificationType.CommunityInvitation:
                    return communityInvitationNotificationComponent
                case ActivityCenterStore.ActivityCenterNotificationType.CommunityMembershipRequest:
                    return membershipRequestNotificationComponent
                case ActivityCenterStore.ActivityCenterNotificationType.CommunityRequest:
                    return communityRequestNotificationComponent
                case ActivityCenterStore.ActivityCenterNotificationType.CommunityKicked:
                    return communityKickedNotificationComponent
                case ActivityCenterStore.ActivityCenterNotificationType.ContactRemoved:
                    return contactRemovedComponent
                case ActivityCenterStore.ActivityCenterNotificationType.NewKeypairAddedToPairedDevice:
                    return newKeypairFromPairedDeviceComponent
                case ActivityCenterStore.ActivityCenterNotificationType.CommunityTokenReceived:
                case ActivityCenterStore.ActivityCenterNotificationType.FirstCommunityTokenReceived:
                    return communityTokenReceivedComponent
                case ActivityCenterStore.ActivityCenterNotificationType.OwnerTokenReceived:
                case ActivityCenterStore.ActivityCenterNotificationType.OwnershipReceived:
                case ActivityCenterStore.ActivityCenterNotificationType.OwnershipLost:
                case ActivityCenterStore.ActivityCenterNotificationType.OwnershipFailed:
                case ActivityCenterStore.ActivityCenterNotificationType.OwnershipDeclined:
                    return ownerTokenReceivedNotificationComponent
                case ActivityCenterStore.ActivityCenterNotificationType.ShareAccounts:
                    return shareAccountsNotificationComponent
                default:
                    return null
                }
            }
        }
    }

    Component {
        id: mentionNotificationComponent

        ActivityNotificationMention {
            filteredIndex: parent.filteredIndex
            notification: parent.notification
            store: root.store
            activityCenterStore: root.activityCenterStore
            onCloseActivityCenter: root.close()
        }
    }
    Component {
        id: replyNotificationComponent

        ActivityNotificationReply {
            filteredIndex: parent.filteredIndex
            notification: parent.notification
            store: root.store
            activityCenterStore: root.activityCenterStore
            onCloseActivityCenter: root.close()
        }
    }
    Component {
        id: contactRequestNotificationComponent

        ActivityNotificationContactRequest {
            filteredIndex: parent.filteredIndex
            notification: parent.notification
            store: root.store
            activityCenterStore: root.activityCenterStore
            onCloseActivityCenter: root.close()
        }
    }
    Component {
        id: verificationRequestNotificationComponent

        ActivityNotificationContactVerification {
            filteredIndex: parent.filteredIndex
            notification: parent.notification
            store: root.store
            activityCenterStore: root.activityCenterStore
            onCloseActivityCenter: root.close()
        }
    }
    Component {
        id: communityInvitationNotificationComponent

        ActivityNotificationCommunityInvitation {
            filteredIndex: parent.filteredIndex
            notification: parent.notification
            store: root.store
            activityCenterStore: root.activityCenterStore
            onCloseActivityCenter: root.close()
        }
    }
    Component {
        id: membershipRequestNotificationComponent

        ActivityNotificationCommunityMembershipRequest {
            filteredIndex: parent.filteredIndex
            notification: parent.notification
            store: root.store
            activityCenterStore: root.activityCenterStore
            onCloseActivityCenter: root.close()
        }
    }
    Component {
        id: communityRequestNotificationComponent

        ActivityNotificationCommunityRequest {
            filteredIndex: parent.filteredIndex
            notification: parent.notification
            store: root.store
            activityCenterStore: root.activityCenterStore
            onCloseActivityCenter: root.close()
        }
    }
    Component {
        id: communityKickedNotificationComponent

        ActivityNotificationCommunityKicked {
            filteredIndex: parent.filteredIndex
            notification: parent.notification
            store: root.store
            activityCenterStore: root.activityCenterStore
            onCloseActivityCenter: root.close()
        }
    }

    Component {
        id: contactRemovedComponent

        ActivityNotificationContactRemoved {
            filteredIndex: parent.filteredIndex
            notification: parent.notification
            store: root.store
            activityCenterStore: root.activityCenterStore
            onCloseActivityCenter: root.close()
        }
    }

    Component {
        id: newKeypairFromPairedDeviceComponent

        ActivityNotificationNewKeypairFromPairedDevice {
            filteredIndex: parent.filteredIndex
            notification: parent.notification
            onCloseActivityCenter: root.close()
        }
    }

    Component {
        id: ownerTokenReceivedNotificationComponent

        ActivityNotificationTransferOwnership {

            readonly property var community : notification ? root.store.getCommunityDetailsAsJson(notification.communityId) : null

            type: setType(notification)

            communityName: community ? community.name : ""
            communityColor: community ? community.color : Theme.palette.directColor1

            filteredIndex: parent.filteredIndex
            notification: parent.notification
            store: root.store
            activityCenterStore: root.activityCenterStore
            onCloseActivityCenter: root.close()

            onFinaliseOwnershipClicked: Global.openFinaliseOwnershipPopup(notification.communityId)
            onNavigateToCommunityClicked: root.store.setActiveCommunity(notification.communityId)
        }
    }

    Component {
        id: communityTokenReceivedComponent

        ActivityNotificationCommunityTokenReceived {

            readonly property var community : notification ? root.store.getCommunityDetailsAsJson(notification.communityId) : null

            communityId: notification.communityId
            communityName: community ? community.name : ""
            communityImage: community ? community.image : ""

            store: root.store

            filteredIndex: parent.filteredIndex
            notification: parent.notification
            onCloseActivityCenter: root.close()
        }
    }

    Component {
        id: shareAccountsNotificationComponent

        ActivityNotificationCommunityShareAddresses {

            readonly property var community : notification ? root.store.getCommunityDetailsAsJson(notification.communityId) : null

            communityName: community ? community.name : ""
            communityColor: community ? community.color : "transparent"
            communityImage: community ? community.image : ""

            filteredIndex: parent.filteredIndex
            notification: parent.notification
            store: root.store
            activityCenterStore: root.activityCenterStore
            onCloseActivityCenter: root.close()

            onOpenShareAccountsClicked: {
                Global.communityShareAddressesPopupRequested(notification.communityId, communityName, communityImage)
            }
        }
    }
}
