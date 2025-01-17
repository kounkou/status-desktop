import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import utils 1.0
import shared.controls 1.0 // Timer

import SortFilterProxyModel 0.2

Control {
    id: root

    property alias currentTabIndex: stackLayout.currentIndex

    property string publicKey
    property string mainDisplayName
    property bool readOnly
    property var profileStore
    property var walletStore
    property var networkConnectionStore

    signal closeRequested()

    onVisibleChanged: if (visible) profileStore.requestProfileShowcase(publicKey)

    horizontalPadding: readOnly ? 20 : 40 // smaller in settings/preview
    topPadding: Style.current.bigPadding

    QtObject {
        id: d

        readonly property string copyLiteral: qsTr("Copy")

        readonly property var timer: Timer {
            id: timer
        }
    }

    background: StatusDialogBackground {
        color: Theme.palette.baseColor4

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: parent.radius
            color: parent.color
        }
    }

    contentItem: StackLayout {
        id: stackLayout

        // communities
        ColumnLayout {
            StatusBaseText {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignCenter
                visible: communitiesView.count == 0
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: Theme.palette.directColor1
                text: qsTr("%1 hasn't joined any communities yet").arg(root.mainDisplayName)
            }

            StatusGridView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                id: communitiesView
                rightMargin: Style.current.halfPadding
                cellWidth: (width-rightMargin)/2
                cellHeight: cellWidth/2
                visible: count
                model: SortFilterProxyModel {
                    sourceModel: root.profileStore.profileShowcaseCommunitiesModel
                    filters: [
                        ValueFilter {
                            roleName: "showcaseVisibility"
                            value: Constants.ShowcaseVisibility.NoOne
                            inverted: true
                        },
                        ValueFilter {
                            roleName: "loading"
                            value: false
                        }
                    ]
                }
                ScrollBar.vertical: StatusScrollBar { }
                delegate: StatusListItem { // TODO custom delegate
                    width: GridView.view.cellWidth - Style.current.smallPadding
                    height: GridView.view.cellHeight - Style.current.smallPadding
                    title: model.name
                    statusListItemTitle.font.pixelSize: 17
                    statusListItemTitle.font.bold: true
                    subTitle: model.description
                    tertiaryTitle: qsTr("%n member(s)", "", model.membersCount)
                    asset.name: model.image ?? model.name
                    asset.isImage: asset.name.startsWith(Constants.dataImagePrefix)
                    asset.isLetterIdenticon: !model.image
                    asset.color: model.color
                    asset.width: 40
                    asset.height: 40
                    border.width: 1
                    border.color: Theme.palette.baseColor2
                    components: [
                        StatusIcon {
                            visible: model.memberRole === Constants.memberRole.owner ||
                                     model.memberRole === Constants.memberRole.admin ||
                                     model.memberRole === Constants.memberRole.tokenMaster
                            anchors.verticalCenter: parent.verticalCenter
                            icon: "crown"
                            color: Theme.palette.directColor1
                        }
                    ]
                    onClicked: {
                        if (root.readOnly)
                            return
                        root.closeRequested()
                        Global.switchToCommunity(model.id)
                    }
                }
            }
        }

        // wallets/accounts
        ColumnLayout {
            StatusBaseText {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignCenter
                visible: accountsView.count == 0
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: Theme.palette.directColor1
                text: qsTr("%1 doesn't have any wallet accounts yet").arg(root.mainDisplayName)
            }

            StatusListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                id: accountsView
                spacing: Style.current.halfPadding
                visible: count
                model: SortFilterProxyModel {
                    sourceModel: root.profileStore.profileShowcaseAccountsModel
                    filters: ValueFilter {
                        roleName: "showcaseVisibility"
                        value: Constants.ShowcaseVisibility.NoOne
                        inverted: true
                    }
                }
                delegate: StatusListItem {
                    id: accountDelegate
                    property bool saved: {
                        let savedAddress = root.walletStore.getSavedAddress(model.address)
                        if (savedAddress.name !== "")
                            return true

                        if (!!root.walletStore.lastCreatedSavedAddress) {
                            if (root.walletStore.lastCreatedSavedAddress.address.toLowerCase() === model.address.toLowerCase()) {
                                return !!root.walletStore.lastCreatedSavedAddress.error
                            }
                        }

                        return false
                    }
                    border.width: 1
                    border.color: Theme.palette.baseColor2
                    width: ListView.view.width
                    title: model.name
                    subTitle: StatusQUtils.Utils.elideText(model.address, 6, 4).replace("0x", "0×")
                    asset.color: Utils.getColorForId(model.colorId)
                    asset.emoji: model.emoji ?? ""
                    asset.name: asset.emoji || "filled-account"
                    asset.isLetterIdenticon: asset.emoji
                    asset.letterSize: 14
                    asset.bgColor: Theme.palette.primaryColor3
                    asset.isImage: asset.emoji
                    components: [
                        StatusIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            icon: "show"
                            color: Theme.palette.directColor1
                        },
                        StatusFlatButton {
                            anchors.verticalCenter: parent.verticalCenter
                            size: StatusBaseButton.Size.Small
                            enabled: !accountDelegate.saved
                            text: accountDelegate.saved ? qsTr("Address saved") : qsTr("Save Address")
                            onClicked: {
                                // From here, we should just run add saved address popup
                                Global.openAddEditSavedAddressesPopup({
                                                                          addAddress: true,
                                                                          address: model.address
                                                                      })
                            }
                        },
                        StatusFlatRoundButton {
                            anchors.verticalCenter: parent.verticalCenter
                            type: StatusFlatRoundButton.Type.Secondary
                            icon.name: "send"
                            tooltip.text: qsTr("Send")
                            enabled: root.networkConnectionStore.sendBuyBridgeEnabled
                            onClicked: {
                                Global.openSendModal(model.address)
                            }
                        },
                        StatusFlatRoundButton {
                            anchors.verticalCenter: parent.verticalCenter
                            type: StatusFlatRoundButton.Type.Secondary
                            icon.name: "copy"
                            tooltip.text: d.copyLiteral
                            onClicked: {
                                tooltip.text = qsTr("Copied")
                                root.profileStore.copyToClipboard(model.address)
                                d.timer.setTimeout(function() {
                                    tooltip.text = d.copyLiteral
                                }, 2000);
                            }
                        }
                    ]
                }
            }
        }

        // collectibles/NFTs
        ColumnLayout {
            StatusBaseText {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignCenter
                visible: collectiblesView.count == 0
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: Theme.palette.directColor1
                text: qsTr("%1 doesn't have any collectibles/NFTs yet").arg(root.mainDisplayName)
            }

            StatusGridView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                id: collectiblesView
                rightMargin: Style.current.halfPadding
                cellWidth: (width-rightMargin)/4
                cellHeight: cellWidth
                visible: count
                // TODO Issue #11637: Dedicated controller for user's list of collectibles (no watch-only entries)
                model: SortFilterProxyModel {
                    sourceModel: root.profileStore.profileShowcaseCollectiblesModel
                    filters: ValueFilter {
                        roleName: "showcaseVisibility"
                        value: Constants.ShowcaseVisibility.NoOne
                        inverted: true
                    }
                }
                ScrollBar.vertical: StatusScrollBar { }
                delegate: StatusRoundedImage {
                    width: GridView.view.cellWidth - Style.current.smallPadding
                    height: GridView.view.cellHeight - Style.current.smallPadding
                    border.width: 1
                    border.color: Theme.palette.directColor7
                    color: !!model.backgroundColor ? model.backgroundColor : "transparent"
                    radius: Style.current.radius
                    showLoadingIndicator: model.isLoading
                    image.fillMode: Image.PreserveAspectCrop
                    image.source: model.imageUrl ?? ""

                    RowLayout {
                        anchors.left: parent.left
                        anchors.leftMargin: Style.current.halfPadding
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: Style.current.halfPadding
                        anchors.right: parent.right
                        anchors.rightMargin: Style.current.halfPadding

                        Control {
                            Layout.maximumWidth: parent.width
                            horizontalPadding: Style.current.halfPadding
                            verticalPadding: Style.current.halfPadding/2
                            visible: !!model.id

                            background: Rectangle {
                                radius: Style.current.halfPadding/2
                                color: Theme.palette.indirectColor2
                            }
                            contentItem: StatusBaseText {
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                maximumLineCount: 1
                                elide: Text.ElideRight
                                text: `#${model.id}`
                            }
                        }
                    }

                    StatusToolTip {
                        visible: hhandler.hovered && (!!model.name || !!model.collectionName)
                        text: {
                            const name = model.name
                            const descr = model.collectionName
                            const sep = !!name && !!descr ? "<br>" : ""
                            return `<b>${name}</b>${sep}${descr}`
                        }
                    }

                    HoverHandler {
                        id: hhandler
                        cursorShape: hovered ? Qt.PointingHandCursor : undefined
                    }

                    TapHandler {
                        onSingleTapped: {
                            Global.openLink(model.permalink)
                        }
                    }
                }
            }
        }

        // assets/tokens
        ColumnLayout {
            StatusBaseText {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignCenter
                visible: assetsView.count == 0
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: Theme.palette.directColor1
                text: qsTr("%1 doesn't have any assets/tokens yet").arg(root.mainDisplayName)
            }

            StatusGridView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                id: assetsView
                rightMargin: Style.current.halfPadding
                cellWidth: (width-rightMargin)/3
                cellHeight: cellWidth/2.5
                visible: count
                model: SortFilterProxyModel {
                    sourceModel: root.profileStore.profileShowcaseAssetsModel
                    filters: ValueFilter {
                        roleName: "showcaseVisibility"
                        value: Constants.ShowcaseVisibility.NoOne
                        inverted: true
                    }
                }
                ScrollBar.vertical: StatusScrollBar { }
                delegate: StatusListItem {
                    readonly property double changePct24hour: model.changePct24hour ?? 0
                    readonly property string textColor: changePct24hour === 0
                                                        ? Theme.palette.baseColor1 : changePct24hour < 0
                                                          ? Theme.palette.dangerColor1 : Theme.palette.successColor1
                    readonly property string arrow: changePct24hour === 0 ? "" : changePct24hour < 0 ? "↓" : "↑"

                    width: GridView.view.cellWidth - Style.current.halfPadding
                    height: GridView.view.cellHeight - Style.current.halfPadding
                    title: model.name
                    //subTitle: LocaleUtils.currencyAmountToLocaleString(model.enabledNetworkBalance)
                    statusListItemTitle.font.weight: Font.Medium
                    tertiaryTitle: qsTr("%1% today %2")
                      .arg(LocaleUtils.numberToLocaleString(changePct24hour, changePct24hour === 0 ? 0 : 2)).arg(arrow)
                    statusListItemTertiaryTitle.color: textColor
                    statusListItemTertiaryTitle.font.pixelSize: Theme.asideTextFontSize
                    statusListItemTertiaryTitle.anchors.topMargin: 6
                    leftPadding: Style.current.halfPadding
                    rightPadding: Style.current.halfPadding
                    border.width: 1
                    border.color: Theme.palette.baseColor2
                    components: [
                        Image {
                            width: 40
                            height: 40
                            anchors.verticalCenter: parent.verticalCenter
                            source: Constants.tokenIcon(model.symbol)
                        }
                    ]
                    onClicked: {
                        if (root.readOnly)
                            return
                        // TODO what to do here?
                    }
                }
            }
        }
    }
}
