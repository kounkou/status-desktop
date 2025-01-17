import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0
import shared.controls 1.0
import shared.views 1.0
import shared.stores 1.0
import shared.panels 1.0

import "./"
import "../stores"
import "../panels"
import "../views/collectibles"

RightTabBaseView {
    id: root

    property alias currentTabIndex: walletTabBar.currentIndex

    signal launchShareAddressModal()

    headerButton.onClicked: {
        root.launchShareAddressModal()
    }

    function resetView() {
        stack.currentIndex = 0
        root.currentTabIndex = 0
        if (walletTabBar.currentIndex === 2)
            mainViewLoader.item.resetView()
    }

    function resetStack() {
        stack.currentIndex = 0;
    }

    StackLayout {
        id: stack
        anchors.fill: parent

        Connections {
            target: walletSection

            function onFilterChanged() {
                root.resetView()
            }
        }

        onCurrentIndexChanged: {
            RootStore.backButtonName = d.getBackButtonText(currentIndex)
        }

        QtObject {
            id: d
            function getBackButtonText(index) {
                switch(index) {
                case 1:
                    return qsTr("Collectibles")
                case 2:
                    return qsTr("Assets")
                case 3:
                    return qsTr("Activity")
                default:
                    return ""
                }
            }
        }

        ColumnLayout {
            spacing: 0

            ImportKeypairInfo {
                Layout.fillWidth: true
                Layout.topMargin: Style.current.bigPadding
                Layout.preferredHeight: childrenRect.height
                visible: root.store.walletSectionInst.hasPairedDevices && root.store.walletSectionInst.keypairOperabilityForObservedAccount === Constants.keypair.operability.nonOperable

                onRunImport: {
                    root.store.walletSectionInst.runKeypairImportPopup()
                }
            }

            RowLayout {
                Layout.fillWidth: true
                StatusTabBar {
                    id: walletTabBar
                    objectName: "rightSideWalletTabBar"
                    Layout.fillWidth: true
                    Layout.topMargin: Style.current.padding

                    StatusTabButton {
                        leftPadding: 0
                        width: implicitWidth
                        text: qsTr("Assets")
                    }
                    StatusTabButton {
                        width: implicitWidth
                        text: qsTr("Collectibles")
                    }
                    StatusTabButton {
                        rightPadding: 0
                        width: implicitWidth
                        text: qsTr("Activity")
                    }
                    onCurrentIndexChanged: {
                        RootStore.setCurrentViewedHoldingType(walletTabBar.currentIndex === 1 ? Constants.TokenType.ERC721 : Constants.TokenType.ERC20)
                    }
                }
                StatusFlatButton {
                    Layout.alignment: Qt.AlignTop
                    id: filterButton
                    icon.name: "filter"
                    checkable: true
                    icon.color: checked ? Theme.palette.primaryColor1 : Theme.palette.baseColor1
                    Behavior on icon.color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                    highlighted: checked
                }
            }
            Loader {
                id: mainViewLoader
                Layout.fillWidth: true
                Layout.fillHeight: true
                sourceComponent: {
                    switch (walletTabBar.currentIndex) {
                    case 0: return assetsView
                    case 1: return collectiblesView
                    case 2: return historyView
                    }
                }

                Component {
                    id: assetsView
                    AssetsView {
                        areAssetsLoading: RootStore.overview.balanceLoading
                        controller: RootStore.walletAssetsStore.assetsController
                        networkFilters: RootStore.networkFilters
                        addressFilters: RootStore.addressFilters
                        overview: RootStore.overview
                        currencyStore: RootStore.currencyStore
                        networkConnectionStore: root.networkConnectionStore
                        assetDetailsLaunched: stack.currentIndex === 2
                        filterVisible: filterButton.checked
                        onAssetClicked: {
                            assetDetailView.token = token
                            RootStore.setCurrentViewedHolding(token.symbol, Constants.TokenType.ERC20)
                            stack.currentIndex = 2
                        }
                        onSendRequested: (symbol) => {
                                            root.sendModal.preSelectedSendType = Constants.SendType.Transfer
                                            root.sendModal.preSelectedHoldingID = symbol
                                            root.sendModal.preSelectedHoldingType = Constants.TokenType.ERC20
                                            root.sendModal.onlyAssets = true
                                            root.sendModal.open()
                                        }
                        onReceiveRequested: (symbol) => root.launchShareAddressModal()
                        onSwitchToCommunityRequested: (communityId) => Global.switchToCommunity(communityId)
                        onManageTokensRequested: Global.changeAppSectionBySectionType(Constants.appSection.profile, Constants.settingsSubsection.wallet,
                                                                                      Constants.walletSettingsSubsection.manageAssets)
                    }
                }
                Component {
                    id: collectiblesView
                    CollectiblesView {
                        controller: RootStore.collectiblesStore.collectiblesController
                        networkFilters: RootStore.networkFilters
                        addressFilters: RootStore.addressFilters
                        sendEnabled: root.networkConnectionStore.sendBuyBridgeEnabled && !RootStore.overview.isWatchOnlyAccount && RootStore.overview.canSend
                        filterVisible: filterButton.checked
                        onCollectibleClicked: {
                            RootStore.collectiblesStore.getDetailedCollectible(chainId, contractAddress, tokenId)
                            RootStore.setCurrentViewedHolding(uid, Constants.TokenType.ERC721)
                            stack.currentIndex = 1
                        }
                        onSendRequested: (symbol) => {
                                            root.sendModal.preSelectedSendType = Constants.SendType.Transfer
                                            root.sendModal.preSelectedHoldingID = symbol
                                            root.sendModal.preSelectedHoldingType = Constants.TokenType.ERC721
                                            root.sendModal.onlyAssets = false
                                            root.sendModal.open()
                                        }
                        onReceiveRequested: (symbol) => root.launchShareAddressModal()
                        onSwitchToCommunityRequested: (communityId) => Global.switchToCommunity(communityId)
                        onManageTokensRequested: Global.changeAppSectionBySectionType(Constants.appSection.profile, Constants.settingsSubsection.wallet,
                                                                                      Constants.walletSettingsSubsection.manageCollectibles)
                        isFetching: RootStore.collectiblesStore.areCollectiblesFetching
                        isUpdating: RootStore.collectiblesStore.areCollectiblesUpdating
                        isError: RootStore.collectiblesStore.areCollectiblesError
                    }
                }
                Component {
                    id: historyView
                    HistoryView {
                        overview: RootStore.overview
                        showAllAccounts: RootStore.showAllAccounts
                        sendModal: root.sendModal
                        filterVisible: filterButton.checked
                        onLaunchTransactionDetail: function (entryIndex) {
                            transactionDetailView.transactionIndex = entryIndex
                            transactionDetailView.transaction = Qt.binding(() => selectedTransaction)
                            stack.currentIndex = 3
                        }
                    }
                }
            }
        }
        CollectibleDetailView {
            collectible: RootStore.collectiblesStore.detailedCollectible
            isCollectibleLoading: RootStore.collectiblesStore.isDetailedCollectibleLoading

            onVisibleChanged: {
                if (!visible)
                    RootStore.resetCurrentViewedHolding(Constants.TokenType.ERC721)
            }
        }
        AssetsDetailView {
            id: assetDetailView

            visible: (stack.currentIndex === 2)

            allNetworksModel: RootStore.allNetworks
            address: RootStore.overview.mixedcaseAddress
            showAllAccounts: RootStore.showAllAccounts
            currencyStore: RootStore.currencyStore
            networkFilters: RootStore.networkFilters

            networkConnectionStore: root.networkConnectionStore

            onVisibleChanged: {
                if (!visible)
                    RootStore.resetCurrentViewedHolding(Constants.TokenType.ERC20)
            }
        }

        TransactionDetailView {
            id: transactionDetailView
            onVisibleChanged: {
                if (visible) {
                    if (!!transaction) {
                        RootStore.addressWasShown(transaction.sender)
                        if (transaction.sender !== transaction.recipient) {
                            RootStore.addressWasShown(transaction.recipient)
                        }
                    }
                } else {
                    transaction = null
                }
            }
            showAllAccounts: RootStore.showAllAccounts
            sendModal: root.sendModal
            contactsStore: root.contactsStore
            networkConnectionStore: root.networkConnectionStore
            visible: (stack.currentIndex === 3)
        }
    }
}
