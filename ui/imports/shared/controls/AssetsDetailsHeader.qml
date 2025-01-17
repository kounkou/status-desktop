﻿import QtQuick 2.13
import QtQuick.Controls 2.14

import utils 1.0
import shared.controls 1.0

import StatusQ 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Controls 0.1

import SortFilterProxyModel 0.2

Control {
    id: root

    property alias primaryText: tokenName.text
    property alias secondaryText: cryptoBalance.text
    property alias tertiaryText: fiatBalance.text
    property var balances
    property int decimals
    property var allNetworksModel
    property bool isLoading: false
    property string errorTooltipText
    property StatusAssetSettings asset: StatusAssetSettings {
        width: 40
        height: 40
    }
    property var formatBalance: function(balance){}

    topPadding: Style.current.padding

    contentItem: Column {
        spacing: 4
        Row {
            spacing: 8
            StatusSmartIdenticon {
                id: identiconLoader
                anchors.verticalCenter: parent.verticalCenter
                asset: root.asset
                loading: root.isLoading
            }
            StatusTextWithLoadingState {
                id: tokenName
                width: Math.min(root.width - identiconLoader.width - cryptoBalance.width - fiatBalance.width - 24, implicitWidth)
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 22
                lineHeight: 30
                lineHeightMode: Text.FixedHeight
                elide: Text.ElideRight
                customColor: Theme.palette.directColor1
                loading: root.isLoading
            }
            StatusTextWithLoadingState {
                id: cryptoBalance
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 22
                lineHeight: 30
                lineHeightMode: Text.FixedHeight
                customColor: Theme.palette.baseColor1
                loading: root.isLoading
            }
            StatusBaseText {
                id: dotSeparator
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -15
                font.pixelSize: 50
                color: Theme.palette.baseColor1
                text: "."
            }
            StatusTextWithLoadingState {
                id: fiatBalance
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 22
                lineHeight: 30
                lineHeightMode: Text.FixedHeight
                customColor: Theme.palette.baseColor1
                loading: root.isLoading
            }
        }

        Row {
            spacing: Style.current.smallPadding
            anchors.left: parent.left
            anchors.leftMargin: identiconLoader.width
            Repeater {
                id: chainRepeater
                model: root.allNetworksModel
                delegate: InformationTag {
                    readonly property double aggregatedbalance: balancesAggregator.value/(10 ** root.decimals)
                    SortFilterProxyModel {
                        id: filteredBalances
                        sourceModel: root.balances
                        filters: ValueFilter {
                            roleName: "chainId"
                            value: model.chainId
                        }
                    }
                    SumAggregator {
                        id: balancesAggregator
                        model: filteredBalances
                        roleName: "balance"
                    }
                    tagPrimaryLabel.text: root.formatBalance(aggregatedbalance)
                    tagPrimaryLabel.color: model.chainColor
                    image.source: Style.svg("tiny/%1".arg(model.iconUrl))
                    loading: root.isLoading
                    visible: balancesAggregator.value > 0
                    rightComponent: StatusFlatRoundButton {
                        width: 14
                        height: visible ? 14 : 0
                        icon.width: 14
                        icon.height: 14
                        icon.name: "tiny/warning"
                        icon.color: Theme.palette.dangerColor1
                        tooltip.text: root.errorTooltipText
                        visible: !!root.errorTooltipText
                    }
                }
            }
        }
    }
}
