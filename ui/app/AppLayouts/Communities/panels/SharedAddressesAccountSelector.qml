import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1

import SortFilterProxyModel 0.2

import utils 1.0

StatusListView {
    id: root

    property var walletAssetsModel
    property bool hasPermissions
    property var uniquePermissionTokenKeys

    // read/write properties
    property string selectedAirdropAddress
    property var selectedSharedAddresses: []

    property var getCurrencyAmount: function (balance, symbol){}

    signal addressesChanged()

    leftMargin: d.absLeftMargin
    topMargin: Style.current.padding
    rightMargin: Style.current.padding
    bottomMargin: Style.current.padding

    QtObject {
        id: d

        // UI
        readonly property int absLeftMargin: 12

        readonly property ButtonGroup airdropGroup: ButtonGroup {
            exclusive: true
        }

        readonly property ButtonGroup addressesGroup: ButtonGroup {
            exclusive: false
        }

        function selectFirstAvailableAirdropAddress() {
            root.selectedAirdropAddress = ModelUtils.modelToFlatArray(root.model, "address").find(address => selectedSharedAddresses.includes(address))
        }

        function getTotalBalance(balances, decimals, symbol) {
            let totalBalance = 0
            for(let i=0; i<balances.count; i++) {
                let balancePerAddressPerChain = ModelUtils.get(balances, i)
                totalBalance += AmountsArithmetic.toNumber(balancePerAddressPerChain.balance, decimals)
            }
            return totalBalance
        }
    }

    spacing: Style.current.halfPadding
    delegate: StatusListItem {
        readonly property string address: model.address.toLowerCase()

        id: listItem
        width: ListView.view.width - ListView.view.leftMargin - ListView.view.rightMargin
        statusListItemTitle.font.weight: Font.Medium
        title: model.name
        tertiaryTitle: !walletAccountAssetsModel.count && root.hasPermissions ? qsTr("No relevant tokens") : ""
        property string accountAddress: model.address

        SubmodelProxyModel {
            id: filteredBalances
            sourceModel: root.walletAssetsModel
            submodelRoleName: "balances"
            delegateModel: SortFilterProxyModel {
                sourceModel: submodel
                filters: FastExpressionFilter {
                    expression: listItem.accountAddress === model.account
                    expectedRoles: ["account"]
                }
            }
        }
        tagsModel: SortFilterProxyModel {
            id: walletAccountAssetsModel
            sourceModel: filteredBalances

            function filterPredicate(symbol) {
                return root.uniquePermissionTokenKeys.includes(symbol.toUpperCase())
            }

            proxyRoles: FastExpressionRole {
                name: "enabledNetworkBalance"
                expression: d.getTotalBalance(model.balances, model.decimals, model.symbol)
                expectedRoles: ["balances", "decimals", "symbol"]
            }
            filters: FastExpressionFilter {
                expression: walletAccountAssetsModel.filterPredicate(model.symbol)
                expectedRoles: ["symbol"]
            }
            sorters: FastExpressionSorter {
                expression: {
                    if (modelLeft.enabledNetworkBalance > modelRight.enabledNetworkBalance)
                        return -1 // descending, biggest first
                    else if (modelLeft.enabledNetworkBalance < modelRight.enabledNetworkBalance)
                        return 1
                    else
                        return 0
                }
                expectedRoles: ["enabledNetworkBalance"]
            }
        }
        statusListItemInlineTagsSlot.spacing: Style.current.padding
        tagsDelegate: Row {
            spacing: 4
            StatusRoundedImage {
                anchors.verticalCenter: parent.verticalCenter
                width: 16
                height: 16
                image.source: Constants.tokenIcon(model.symbol.toUpperCase())
            }
            StatusBaseText {
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: Theme.tertiaryTextFontSize
                text: LocaleUtils.currencyAmountToLocaleString(root.getCurrencyAmount(model.enabledNetworkBalance, model.symbol))
            }
        }

        asset.color: !!model.color ? model.color : ""
        asset.emoji: model.emoji
        asset.name: !model.emoji ? "filled-account": ""
        asset.letterSize: 14
        asset.isLetterIdenticon: !!model.emoji
        asset.isImage: asset.isLetterIdenticon

        components: [
            StatusFlatButton {
                ButtonGroup.group: d.airdropGroup
                anchors.verticalCenter: parent.verticalCenter
                icon.name: "airdrop"
                icon.color: hovered ? Theme.palette.primaryColor3 :
                                      checked ? Theme.palette.primaryColor1 : disabledTextColor
                checkable: true
                checked: listItem.address === root.selectedAirdropAddress.toLowerCase()
                enabled: shareAddressCheckbox.checked && root.selectedSharedAddresses.length > 1 // last cannot be unchecked
                visible: shareAddressCheckbox.checked
                opacity: enabled ? 1.0 : 0.3
                onCheckedChanged: if (checked) root.selectedAirdropAddress = listItem.address
                onToggled: root.addressesChanged()

                StatusToolTip {
                    text: qsTr("Use this address for any Community airdrops")
                    visible: parent.hovered
                    delay: 500
                }
            },
            StatusCheckBox {
                id: shareAddressCheckbox
                ButtonGroup.group: d.addressesGroup
                anchors.verticalCenter: parent.verticalCenter
                checkable: true
                checked: root.selectedSharedAddresses.some((address) => address.toLowerCase() === listItem.address )
                enabled: !(root.selectedSharedAddresses.length === 1 && checked) // last cannot be unchecked
                onToggled: {
                    // handle selected addresses
                    const index = root.selectedSharedAddresses.findIndex((address) => address.toLowerCase() === listItem.address)
                    const selectedSharedAddressesCopy = Object.assign([], root.selectedSharedAddresses) // deep copy
                    if (index === -1) {
                        selectedSharedAddressesCopy.push(listItem.address)
                    } else {
                        selectedSharedAddressesCopy.splice(index, 1)
                    }
                    root.selectedSharedAddresses = selectedSharedAddressesCopy

                    // switch to next available airdrop address when unchecking
                    if (!checked && listItem.address === root.selectedAirdropAddress.toLowerCase()) {
                        d.selectFirstAvailableAirdropAddress()
                    }

                    root.addressesChanged()
                }
            }
        ]
    }
}
