import NimQml, json, strformat, sequtils, strutils, logging, stint, strutils

import ../transactions/view
import ../transactions/item
import ./backend/transactions
import backend/activity as backend
import ../../../shared_models/currency_amount

# Additional data needed to build an Entry, which is
# not included in the metadata and needs to be
# fetched from a different source.
type
  ExtraData* = object
    inAmount*: float64
    outAmount*: float64
    # TODO: Fields below should come from the metadata
    inSymbol*: string
    outSymbol*: string

# It is used to display an activity history entry in the QML UI
#
# TODO add all required metadata from filtering
#
# Looking into going away from carying the whole detailed data and just keep the required data for the UI
# and request the detailed data on demand
#
# Outdated: The ActivityEntry contains one of the following instances transaction, pending transaction or multi-transaction
QtObject:
  type
    ActivityEntry* = ref object of QObject
      # TODO: these should be removed
      multi_transaction: MultiTransactionDto
      transaction: ref Item
      isPending: bool
      activityType: backend.ActivityType

      metadata: backend.ActivityEntry
      extradata: ExtraData

  proc setup(self: ActivityEntry) =
    self.QObject.setup

  proc delete*(self: ActivityEntry) =
    self.QObject.delete

  proc newMultiTransactionActivityEntry*(mt: MultiTransactionDto, metadata: backend.ActivityEntry, extradata: ExtraData): ActivityEntry =
    new(result, delete)
    result.multi_transaction = mt
    result.transaction = nil
    result.isPending = false
    result.metadata = metadata
    result.extradata = extradata
    result.setup()

  proc newTransactionActivityEntry*(tr: ref Item, metadata: backend.ActivityEntry, fromAddresses: seq[string], extradata: ExtraData): ActivityEntry =
    new(result, delete)
    result.multi_transaction = nil
    result.transaction = tr
    result.isPending = metadata.payloadType == backend.PayloadType.PendingTransaction
    result.metadata = metadata
    result.extradata = extradata
    result.activityType = backend.ActivityType.Send
    if tr != nil:
      for address in fromAddresses:
        if (cmpIgnoreCase(address, tr[].getTo()) == 0):
          result.activityType = backend.ActivityType.Receive
          break
    result.setup()

  proc isMultiTransaction*(self: ActivityEntry): bool {.slot.} =
    return self.multi_transaction != nil

  QtProperty[bool] isMultiTransaction:
    read = isMultiTransaction

  proc isPendingTransaction*(self: ActivityEntry): bool {.slot.} =
    return (not self.isMultiTransaction()) and self.isPending

  QtProperty[bool] isPendingTransaction:
    read = isPendingTransaction

  proc `$`*(self: ActivityEntry): string =
    let mtStr = if self.multi_transaction != nil: $(self.multi_transaction.id) else: "0"
    let trStr = if self.transaction != nil: $(self.transaction[]) else: "nil"

    return fmt"""ActivityEntry(
      multi_transaction.id:{mtStr},
      transaction:{trStr},
      isPending:{self.isPending}
    )"""

  proc getMultiTransaction*(self: ActivityEntry): MultiTransactionDto =
    if not self.isMultiTransaction():
      raise newException(Defect, "ActivityEntry is not a MultiTransaction")
    return self.multi_transaction

  proc getTransaction*(self: ActivityEntry, pending: bool): ref Item =
    if self.isMultiTransaction() or self.isPending != pending:
      raise newException(Defect, "ActivityEntry is not a " & (if pending: "pending" else: "") & " Transaction")
    return self.transaction

  proc getSender*(self: ActivityEntry): string {.slot.} =
    # TODO: lookup sender's name
    if self.isMultiTransaction():
      return self.multi_transaction.fromAddress

    return self.transaction[].getfrom()

  QtProperty[string] sender:
    read = getSender

  proc getRecipient*(self: ActivityEntry): string {.slot.} =
    # TODO: lookup recipient name
    if self.isMultiTransaction():
      return self.multi_transaction.toAddress

    return self.transaction[].getTo()

  QtProperty[string] recipient:
    read = getRecipient

  proc getInAmount*(self: ActivityEntry): float {.slot.} =
    return float(self.extradata.inAmount)

  QtProperty[float] inAmount:
    read = getInAmount

  proc getOutAmount*(self: ActivityEntry): float {.slot.} =
    return float(self.extradata.outAmount)

  QtProperty[float] outAmount:
    read = getOutAmount


  proc getInSymbol*(self: ActivityEntry): string {.slot.} =
    return self.extradata.inSymbol

  QtProperty[string] inSymbol:
    read = getInSymbol

  proc getOutSymbol*(self: ActivityEntry): string {.slot.} =
    return self.extradata.outSymbol

  QtProperty[string] outSymbol:
    read = getOutSymbol

  proc getTimestamp*(self: ActivityEntry): int {.slot.} =
    if self.isMultiTransaction():
      return self.multi_transaction.timestamp
    # TODO: should we account for self.transaction[].isTimeStamp?
    return self.transaction[].getTimestamp()

  QtProperty[int] timestamp:
    read = getTimestamp

  proc getStatus*(self: ActivityEntry): int {.slot.} =
    return self.metadata.activityStatus.int

  QtProperty[int] status:
    read = getStatus

  proc getChainId*(self: ActivityEntry): int {.slot.} =
    if self.transaction == nil:
      error "getChainId: ActivityEntry is not an transaction.Item"
      return 0
    return self.transaction[].getChainId()

  QtProperty[int] chainId:
    read = getChainId

  proc getIsNFT*(self: ActivityEntry): bool {.slot.} =
    if self.transaction == nil:
      error "getIsNFT: ActivityEntry is not an transaction.Item"
      return false
    return self.transaction[].getIsNFT()

  QtProperty[int] isNFT:
    read = getIsNFT

  proc getNFTName*(self: ActivityEntry): string {.slot.} =
    if self.transaction == nil:
      error "getNFTName: ActivityEntry is not an transaction.Item"
      return ""
    return self.transaction[].getNFTName()

  QtProperty[string] nftName:
    read = getNFTName

  proc getNFTImageURL*(self: ActivityEntry): string {.slot.} =
    if self.transaction == nil:
      error "getNFTImageURL: ActivityEntry is not an transaction.Item"
      return ""
    return self.transaction[].getNFTImageURL()

  QtProperty[string] nftImageURL:
    read = getNFTImageURL

  proc getTotalFees*(self: ActivityEntry): QVariant {.slot.} =
    if self.transaction == nil:
      error "getTotalFees: ActivityEntry is not an transaction.Item"
      return newQVariant(0)
    return newQVariant(self.transaction[].getTotalFees())

  QtProperty[QVariant] totalFees:
    read = getTotalFees

  proc getInput*(self: ActivityEntry): string {.slot.} =
    if self.transaction == nil:
      error "getInput: ActivityEntry is not an transaction.Item"
      return ""
    return self.transaction[].getInput()

  QtProperty[string] input:
    read = getInput

  proc getTxType*(self: ActivityEntry): int {.slot.} =
    return self.activityType.int

  QtProperty[int] txType:
    read = getTxType

  proc getType*(self: ActivityEntry): string {.slot.} =
    if self.transaction == nil:
      error "getType: ActivityEntry is not an transaction.Item"
      return ""
    return self.transaction[].getType()

  QtProperty[string] type:
    read = getType

  proc getContract*(self: ActivityEntry): string {.slot.} =
    if self.transaction == nil:
      error "getContract: ActivityEntry is not an transaction.Item"
      return ""
    return self.transaction[].getContract()

  QtProperty[string] contract:
    read = getContract

  proc getTxHash*(self: ActivityEntry): string {.slot.} =
    if self.transaction == nil:
      error "getTxHash: ActivityEntry is not an transaction.Item"
      return ""
    return self.transaction[].getTxHash()

  QtProperty[string] txHash:
    read = getTxHash

  proc getTokenID*(self: ActivityEntry): string {.slot.} =
    if self.transaction == nil:
      error "getTokenID: ActivityEntry is not an transaction.Item"
      return ""
    return $self.transaction[].getTokenID()

  QtProperty[string] tokenID:
    read = getTokenID

  proc getNonce*(self: ActivityEntry): string {.slot.} =
    if self.transaction == nil:
      error "getNonce: ActivityEntry is not an transaction.Item"
      return ""
    return $self.transaction[].getNonce()

  QtProperty[string] nonce:
    read = getNonce

# TODO: Replaced usage of these for in/out versions in the QML modules
  proc getSymbol*(self: ActivityEntry): string {.slot.} =
    if self.transaction == nil:
      error "getSymbol: ActivityEntry is not an transaction.Item"
      return ""

    if self.activityType == backend.ActivityType.Receive:
      return self.getInSymbol()

    return self.getOutSymbol()

  QtProperty[string] symbol:
    read = getSymbol

  proc getFromAmount*(self: ActivityEntry): float {.slot.} =
    if self.isMultiTransaction():
      return self.getOutAmount()
    error "getFromAmount: ActivityEntry is not a MultiTransaction"
    return 0.0

  QtProperty[float] fromAmount:
    read = getFromAmount

  proc getToAmount*(self: ActivityEntry): float {.slot.} =
    if self.isMultiTransaction():
      return self.getInAmount()
    error "getToAmount: ActivityEntry is not a MultiTransaction"
    return 0.0

  QtProperty[float] toAmount:
    read = getToAmount

  proc getValue*(self: ActivityEntry): float {.slot.} =
    if self.isMultiTransaction():
      error "getToAmount: ActivityEntry is a MultiTransaction"
      return 0.0

    if self.activityType == backend.ActivityType.Receive:
      return self.getInAmount()

    # For some reason status-go is categorizing every activity as Receive,
    # inverting the In/Out fields for Send operations. Revert this when
    # that gets fixed.
    #return self.getOutAmount()
    return self.getInAmount()

  QtProperty[float] value:
    read = getValue