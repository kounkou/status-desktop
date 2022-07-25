import QtQuick 2.14
import QtQuick.Layouts 1.4

import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import utils 1.0
import shared 1.0
import shared.controls 1.0
import shared.panels 1.0
import shared.views 1.0
import shared.status 1.0

ColumnLayout {
    id: root

    property string headerTitle: ""

    property var rootStore
    property var contactsStore
    property var community

    property var pubKeys: ([])

    spacing: Style.current.padding

    StyledText {
        id: headline
        text: qsTr("Contacts")
        font.pixelSize: Style.current.primaryTextFontSize
        color: Style.current.secondaryText
    }

    StatusInput {
        id: filterInput
        placeholderText: qsTr("Search contacts")
        input.icon.name: "search"
        input.clearable: true
        Layout.fillWidth: true
    }

    ExistingContacts {
        id: existingContacts

        contactsStore: root.contactsStore
        community: root.community
        hideCommunityMembers: true
        showCheckbox: true
        filterText: filterInput.text
        pubKeys: root.pubKeys
        onContactClicked: function (contact) {
            if (!contact || typeof contact === "string") {
                return
            }
            const index = root.pubKeys.indexOf(contact.pubKey)
            const pubKeysCopy = Object.assign([], root.pubKeys)
            if (index === -1) {
                pubKeysCopy.push(contact.pubKey)
            } else {
                pubKeysCopy.splice(index, 1)
            }
            root.pubKeys = pubKeysCopy
        }
        Layout.rightMargin: -Style.current.padding
        Layout.fillWidth: true
        Layout.fillHeight: true
    }

    StatusModalDivider {
        bottomPadding: Style.current.padding
        Layout.fillWidth: true
    }

    StatusDescriptionListItem {
        title: qsTr("Share community")
        subTitle: `${Constants.communityLinkPrefix}${root.community && root.community.id.substring(0, 4)}...${root.community && root.community.id.substring(root.community.id.length -2)}`
        tooltip.text: qsTr("Copied!")
        icon.name: "copy"
        iconButton.onClicked: {
            let link = `${Constants.communityLinkPrefix}${root.community.id}`
            root.rootStore.copyToClipboard(link)
            tooltip.visible = !tooltip.visible
        }
    }
}
