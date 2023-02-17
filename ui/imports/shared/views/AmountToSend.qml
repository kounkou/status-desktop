import QtQuick 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls.Validators 0.1

import "../controls"

import utils 1.0

ColumnLayout {
    id: root

    property alias input: topAmountToSendInput
    readonly property double inputNumber: topAmountToSendInput.text ? LocaleUtils.numberFromLocaleString(topAmountToSendInput.text) : 0

    property string selectedSymbol
    property bool isBridgeTx: false
    property bool interactive: false
    property double maxInputBalance
    property bool inputIsFiat: false
    property double cryptoValueToSend
    Binding {
        target: root
        property: "cryptoValueToSend"
        value: {
            const value = !inputIsFiat ? inputNumber : getCryptoValue(fiatValueToSend)
            return root.selectedSymbol, value
        }
        delayed: true
    }
    property var fiatValueToSend
    Binding {
        target: root
        property: "fiatValueToSend"
        value: {
            const value = inputIsFiat ? inputNumber : getFiatValue(cryptoValueToSend)
            return root.selectedSymbol, value
        }
        delayed: true
    }
    property string currentCurrency
    property var getFiatValue: function(cryptoValue) {}
    property var getCryptoValue: function(fiatValue) {}
    property var formatCurrencyAmount: function() {}

    signal reCalculateSuggestedRoute()

    QtObject {
        id: d
        readonly property string zeroString: LocaleUtils.numberToLocaleString(0, 2)
        property Timer waitTimer: Timer {
            interval: 1000
            onTriggered: reCalculateSuggestedRoute()
        }
    }

    onMaxInputBalanceChanged: {
        floatValidator.top = maxInputBalance
        input.validate()
    }

    StatusBaseText {
        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
        text: root.isBridgeTx ? qsTr("Amount to bridge") : qsTr("Amount to send")
        font.pixelSize: 13
        lineHeight: 18
        lineHeightMode: Text.FixedHeight
        color: Theme.palette.directColor1
    }
    RowLayout {
        id: topItem
        property double topAmountToSend: !inputIsFiat ? cryptoValueToSend : fiatValueToSend
        property string topAmountSymbol: !inputIsFiat ? root.selectedSymbol : root.currentCurrency
        Layout.alignment: Qt.AlignLeft
        AmountInputWithCursor {
            id: topAmountToSendInput
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            Layout.maximumWidth: 163
            Layout.preferredWidth: (!!text) ? input.edit.paintedWidth : textMetrics.advanceWidth
            placeholderText: d.zeroString
            input.edit.color: input.valid ? Theme.palette.directColor1 : Theme.palette.dangerColor1
            input.edit.readOnly: !root.interactive
            validators: [
                StatusFloatValidator {
                    id: floatValidator
                    bottom: 0
                    top: root.maxInputBalance
                    errorMessage: ""
                }
            ]
            TextMetrics {
                id: textMetrics
                text: topAmountToSendInput.placeholderText
                font: topAmountToSendInput.input.placeholder.font
            }
            Keys.onReleased: {
                const amount = topAmountToSendInput.text.trim()
                if (!Utils.containsOnlyDigits(amount) || isNaN(amount)) {
                    return
                }
                d.waitTimer.restart()
            }
        }
    }
    Item {
        id: bottomItem
        property double bottomAmountToSend: inputIsFiat ? cryptoValueToSend : fiatValueToSend
        property string bottomAmountSymbol: inputIsFiat ? selectedSymbol : currentCurrency
        Layout.alignment: Qt.AlignLeft | Qt.AlignBottom
        Layout.preferredWidth: txtBottom.width
        Layout.preferredHeight: txtBottom.height
        StatusBaseText {
            id: txtBottom
            anchors.top: parent.top
            anchors.left: parent.left
            text: root.formatCurrencyAmount(bottomItem.bottomAmountToSend, bottomItem.bottomAmountSymbol)
            font.pixelSize: 13
            color: Theme.palette.directColor5
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                topAmountToSendInput.validate()
                if(!!topAmountToSendInput.text) {
                    topAmountToSendInput.text = root.formatCurrencyAmount(bottomItem.bottomAmountToSend, bottomItem.bottomAmountSymbol, {onlyAmount: true})
                }
                inputIsFiat = !inputIsFiat
                d.waitTimer.restart()
            }
        }
    }
}

