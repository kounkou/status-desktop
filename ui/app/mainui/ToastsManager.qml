import QtQuick 2.15

import utils 1.0

import AppLayouts.Wallet 1.0

import AppLayouts.stores 1.0
import AppLayouts.Chat.stores 1.0 as ChatStores

import shared.stores 1.0 as SharedStores

// The purpose of this class is to be the central point for generating toasts in the application.
// It will have as input all needed stores.
// In case the file grows considerably, consider creating different toasts managers per topic / context
// and just instantiate them in here.
QtObject {
    id: root

    // Here there are defined some specific actions needed by a toast.
    // They are normally specific navigations or open popup action.
    enum ActionType {
        None = 0,
        NavigateToCommunityAdmin = 1,
        OpenFinaliseOwnershipPopup = 2,
        OpenSendModalPopup = 3,
        ViewTransactionDetails = 4,
        OpenFirstCommunityTokenPopup = 5
    }

    // Stores:
    required property RootStore rootStore
    required property ChatStores.RootStore rootChatStore
    required property SharedStores.CommunityTokensStore communityTokensStore

    // Properties:
    required property var sendModalPopup

    // Utils:
    readonly property string viewOptimismExplorerText: qsTr("View on Optimism Explorer")
    readonly property string checkmarkCircleAssetName: "checkmark-circle"
    readonly property string crownOffAssetName: "crown-off"

    // Community Transfer Ownership related toasts:
    readonly property Connections _communityTokensStoreConnections: Connections {
        target: root.communityTokensStore

        // Ownership Receiver:
        function onOwnerTokenReceived(communityId, communityName) {
            let communityColor = root.rootChatStore.getCommunityDetailsAsJson(communityId).color
            Global.displayToastWithActionMessage(qsTr("You received the Owner token for %1. To finalize ownership, make your device the control node.").arg(communityName),
                                                 qsTr("Finalise ownership"),
                                                 "crown",
                                                 communityColor,
                                                 false,
                                                 Constants.ephemeralNotificationType.normal,
                                                 ToastsManager.ActionType.OpenFinaliseOwnershipPopup,
                                                 communityId)
        }

        function onSetSignerStateChanged(communityId, communityName, status, url) {
            if (status === Constants.ContractTransactionStatus.Completed) {
                Global.displayToastMessage(qsTr("%1 smart contract amended").arg(communityName),
                                           root.viewOptimismExplorerText,
                                           root.checkmarkCircleAssetName,
                                           false,
                                           Constants.ephemeralNotificationType.success,
                                           url)
                Global.displayToastWithActionMessage(qsTr("Your device is now the control node for %1. You now have full Community admin rights.").arg(communityName),
                                                     qsTr("%1 Community admin").arg(communityName),
                                                     root.checkmarkCircleAssetName,
                                                     "",
                                                     false,
                                                     Constants.ephemeralNotificationType.success,
                                                     ToastsManager.ActionType.NavigateToCommunityAdmin,
                                                     communityId)
            } else if (status === Constants.ContractTransactionStatus.Failed) {
                Global.displayToastMessage(qsTr("%1 smart contract update failed").arg(communityName),
                                           root.viewOptimismExplorerText,
                                           "warning",
                                           false,
                                           Constants.ephemeralNotificationType.danger,
                                           url)
            } else if (status ===  Constants.ContractTransactionStatus.InProgress) {
                Global.displayToastMessage(qsTr("Updating %1 smart contract").arg(communityName),
                                           root.viewOptimismExplorerText,
                                           "",
                                           true,
                                           Constants.ephemeralNotificationType.normal,
                                           url)
            }
        }

        function onCommunityOwnershipDeclined(communityName) {
            Global.displayToastWithActionMessage(qsTr("You declined ownership of %1.").arg(communityName),
                                                 qsTr("Return owner token to sender"),
                                                 root.crownOffAssetName,
                                                 "",
                                                 false,
                                                 Constants.ephemeralNotificationType.danger,
                                                 ToastsManager.ActionType.OpenSendModalPopup,
                                                 "")
        }

        // Ownership Sender:
        function onSendOwnerTokenStateChanged(tokenName, status, url) {
            if (status === Constants.ContractTransactionStatus.InProgress) {
                Global.displayToastMessage(qsTr("Sending %1 token").arg(tokenName),
                                           root.viewOptimismExplorerText,
                                           "",
                                           true,
                                           Constants.ephemeralNotificationType.normal, url)
            } else if (status ===  Constants.ContractTransactionStatus.Completed) {
                Global.displayToastMessage(qsTr("%1 token sent").arg(tokenName),
                                           root.viewOptimismExplorerText,
                                           root.checkmarkCircleAssetName,
                                           false,
                                           Constants.ephemeralNotificationType.success, url)
            }
        }

        function onOwnershipLost(communityId, communityName) {
            Global.displayToastMessage(qsTr("Your device is no longer the control node for %1.
                                             Your ownership and admin rights for %1 have been transferred to the new owner.").arg(communityName),
                                       "",
                                       root.crownOffAssetName,
                                       false,
                                       Constants.ephemeralNotificationType.danger,
                                       "")
        }

        // Community token received in the user wallet:
        function onCommunityTokenReceived(name, symbol, image, communityId, communityName, balance, chainId, txHash, isFirst, tokenType, walletAccountName) {

            // Some error control:
            if(tokenType !== Constants.TokenType.ERC20 && tokenType !== Constants.TokenType.ERC721) {
                console.warn("Community token Received: Unexpected token type while creating a toast message: " + tokenType)
                return
            }

            // Double check if balance is string, then strip ending zeros (e.g. 1.0 -> 1)
            if (typeof balance === 'string' && balance.endsWith('0')) {
                balance = parseFloat(balance)
                if (isNaN(balance))
                    balance = "1"
                // Cast to Number to drop trailing zeros
                balance = Number(balance).toString()
            }

            var data = {
                communityId: communityId,
                communityName: communityName,
                chainId: chainId,
                txHash: txHash,
                tokenType: tokenType,
                tokenName: name,
                tokenSymbol: symbol,
                tokenImage: image,
                tokenAmount: balance
            }

            if(isFirst) {
                var tokenTypeText = ""
                if(tokenType === Constants.TokenType.ERC20) {
                    tokenTypeText = qsTr("You received your first community asset")
                } else if(tokenType === Constants.TokenType.ERC721) {
                    tokenTypeText = qsTr("You received your first community collectible")
                }

                // First community token received toast:
                Global.displayImageToastWithActionMessage(qsTr("%1: %2 %3").arg(tokenTypeText).arg(balance).arg(name),
                                                          qsTr("Learn more"),
                                                          image,
                                                          Constants.ephemeralNotificationType.normal,
                                                          ToastsManager.ActionType.OpenFirstCommunityTokenPopup,
                                                          JSON.stringify(data))
            } else {
                // Generic community token received toast:
                Global.displayImageToastWithActionMessage(qsTr("You were airdropped %1 %2 from %3 to %4").arg(balance).arg(name).arg(communityName).arg(walletAccountName),
                                                          qsTr("View transaction details"),
                                                          image,
                                                          Constants.ephemeralNotificationType.normal,
                                                          ToastsManager.ActionType.ViewTransactionDetails,
                                                          JSON.stringify(data))
            }
        }
    }

    // Connections to global. These will lead the backend integration:
    readonly property Connections _globalConnections: Connections {
        target: Global

        function onDisplayToastMessage(title: string, subTitle: string, icon: string, loading: bool, ephNotifType: int, url: string) {
            root.rootStore.mainModuleInst.displayEphemeralNotification(title, subTitle, icon, loading, ephNotifType, url)
        }

        // TO UNIFY with the one above.
        // Further refactor will be done in a next step
        function onDisplayToastWithActionMessage(title: string, subTitle: string, icon: string, iconColor: string, loading: bool, ephNotifType: int, actionType: int, actionData: string) {
            root.rootStore.mainModuleInst.displayEphemeralWithActionNotification(title, subTitle, icon, iconColor, loading, ephNotifType, actionType, actionData)
        }

        function onDisplayImageToastWithActionMessage(title: string, subTitle: string, image: string, ephNotifType: int, actionType: int, actionData: string) {
            root.rootStore.mainModuleInst.displayEphemeralImageWithActionNotification(title, subTitle, image, ephNotifType, actionType, actionData)
        }
    }

    // It will cover all specific actions (different than open external links) that can be done after clicking toast link text
    function doAction(actionType, actionData) {
        switch(actionType) {
        case ToastsManager.ActionType.NavigateToCommunityAdmin:
            root.rootChatStore.setActiveCommunity(actionData)
            return
        case ToastsManager.ActionType.OpenFinaliseOwnershipPopup:
            Global.openFinaliseOwnershipPopup(actionData)
            return
        case ToastsManager.ActionType.OpenSendModalPopup:
            root.sendModalPopup.open()
            return
        case ToastsManager.ActionType.ViewTransactionDetails:
            var txHash = ""
            if(actionData) {
                var parsedData = JSON.parse(actionData)
                txHash = parsedData.txHash
                Global.changeAppSectionBySectionType(Constants.appSection.wallet,
                                                     WalletLayout.LeftPanelSelection.AllAddresses,
                                                     WalletLayout.RightPanelSelection.Activity)
                // TODO: Final navigation to the specific transaction entry --> {transaction: txHash}) --> Issue #13249
                return
            }
            console.warn("Unexpected transaction hash while trying to navigate to the details page: " + txHash)
            return
        case ToastsManager.ActionType.OpenFirstCommunityTokenPopup:
            if(actionData) {
                var data = JSON.parse(actionData)
                var communityId = data.communityId
                var communityName = data.communityName
                var tokenType = data.tokenType
                var tokenName = data.tokenName
                var tokenSymbol = data.tokenSymbol
                var tokenImage = data.tokenImage
                var tokenAmount = data.tokenAmount
                Global.openFirstTokenReceivedPopup(communityId,
                                                   communityName,
                                                   rootChatStore.getCommunityDetailsAsJson(communityId).image,
                                                   tokenSymbol,
                                                   tokenName,
                                                   tokenAmount,
                                                   tokenType,
                                                   tokenImage);
            }
            return
        default:
            console.warn("ToastsManager: Action type is not defined")
            return
        }
    }
}
