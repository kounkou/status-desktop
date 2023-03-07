import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import utils 1.0

import "views"
import "stores"
import "popups/community"

StackLayout {
    id: root

    property RootStore rootStore
    readonly property var contactsStore: rootStore.contactsStore

    property var emojiPopup
    property var stickersPopup
    signal importCommunityClicked()
    signal createCommunityClicked()
    signal profileButtonClicked()
    signal openAppSearch()

    onCurrentIndexChanged: {
        Global.closeCreateChatView()
    }

    Component {
        id: membershipRequestPopupComponent
        MembershipRequestsPopup {
            anchors.centerIn: parent
            store: root.rootStore
            communityData: store.mainModuleInst ? store.mainModuleInst.activeSection || {} : {}
            onClosed: {
                destroy()
            }
        }
    }

    ChatView {
        id: chatView
        emojiPopup: root.emojiPopup
        stickersPopup: root.stickersPopup
        contactsStore: root.contactsStore
        rootStore: root.rootStore
        membershipRequestPopup: membershipRequestPopupComponent

        onCommunityInfoButtonClicked: root.currentIndex = 1
        onCommunityManageButtonClicked: root.currentIndex = 1

        onImportCommunityClicked: {
            root.importCommunityClicked();
        }
        onCreateCommunityClicked: {
            root.createCommunityClicked();
        }
        onProfileButtonClicked: {
            root.profileButtonClicked()
        }
        onOpenAppSearch: {
            root.openAppSearch()
        }
    }

    Loader {
        active: root.rootStore.chatCommunitySectionModule.isCommunity()

        sourceComponent: CommunitySettingsView {
            rootStore: root.rootStore
            communityStore: CommunitiesStore {}

            hasAddedContacts: root.contactsStore.myContactsModel.count > 0
            chatCommunitySectionModule: root.rootStore.chatCommunitySectionModule
            community: root.rootStore.mainModuleInst ? root.rootStore.mainModuleInst.activeSection
                                                       || ({}) : ({})

            onBackToCommunityClicked: root.currentIndex = 0

            // TODO: remove me when migration to new settings is done
            onOpenLegacyPopupClicked: Global.openCommunityProfilePopupRequested(root.rootStore, community, chatCommunitySectionModule)
        }
    }
}
