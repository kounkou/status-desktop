import json, json_serialization

include ../../../common/json_utils

type ProfileShowcaseCommunity* = ref object of RootObj
  communityId*: string
  order*: int

type ProfileShowcaseAccount* = ref object of RootObj
  contactId*: string
  address*: string
  name*: string
  colorId*: string
  emoji*: string
  order*: int

type ProfileShowcaseCollectible* = ref object of RootObj
  contractAddress*: string
  chainId*: int
  tokenId*: string
  communityId*: string
  accountAddress*: string
  order*: int

type ProfileShowcaseVerifiedToken* = ref object of RootObj
  symbol*: string
  order*: int

type ProfileShowcaseUnverifiedToken* = ref object of RootObj
  contractAddress*: string
  chainId*: int
  order*: int

type ProfileShowcaseDto* = ref object of RootObj
  contactId*: string
  communities*: seq[ProfileShowcaseCommunity]
  accounts*: seq[ProfileShowcaseAccount]
  collectibles*: seq[ProfileShowcaseCollectible]
  verifiedTokens*: seq[ProfileShowcaseVerifiedToken]
  unverifiedTokens*: seq[ProfileShowcaseUnverifiedToken]

proc toProfileShowcaseCommunity*(jsonObj: JsonNode): ProfileShowcaseCommunity =
  result = ProfileShowcaseCommunity()
  discard jsonObj.getProp("communityId", result.communityId)
  discard jsonObj.getProp("order", result.order)

proc toProfileShowcaseAccount*(jsonObj: JsonNode): ProfileShowcaseAccount =
  result = ProfileShowcaseAccount()
  discard jsonObj.getProp("contactId", result.contactId)
  discard jsonObj.getProp("address", result.address)
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("colorId", result.colorId)
  discard jsonObj.getProp("emoji", result.emoji)
  discard jsonObj.getProp("order", result.order)

proc toProfileShowcaseCollectible*(jsonObj: JsonNode): ProfileShowcaseCollectible =
  result = ProfileShowcaseCollectible()
  discard jsonObj.getProp("chainId", result.chainId)
  discard jsonObj.getProp("tokenId", result.tokenId)
  discard jsonObj.getProp("contractAddress", result.contractAddress)
  discard jsonObj.getProp("communityId", result.communityId)
  discard jsonObj.getProp("accountAddress", result.accountAddress)
  discard jsonObj.getProp("order", result.order)

proc toProfileShowcaseVerifiedToken*(jsonObj: JsonNode): ProfileShowcaseVerifiedToken =
  result = ProfileShowcaseVerifiedToken()
  discard jsonObj.getProp("symbol", result.symbol)
  discard jsonObj.getProp("order", result.order)

proc toProfileShowcaseUnverifiedToken*(jsonObj: JsonNode): ProfileShowcaseUnverifiedToken =
  result = ProfileShowcaseUnverifiedToken()
  discard jsonObj.getProp("contractAddress", result.contractAddress)
  discard jsonObj.getProp("chainId", result.chainId)
  discard jsonObj.getProp("order", result.order)

proc toProfileShowcaseDto*(jsonObj: JsonNode): ProfileShowcaseDto =
  result = ProfileShowcaseDto()

  discard jsonObj.getProp("contactId", result.contactId)

  if jsonObj["communities"].kind != JNull:
    for jsonMsg in jsonObj["communities"]:
      result.communities.add(jsonMsg.toProfileShowcaseCommunity())
  if jsonObj["accounts"].kind != JNull:
    for jsonMsg in jsonObj["accounts"]:
      result.accounts.add(jsonMsg.toProfileShowcaseAccount())
  if jsonObj["collectibles"].kind != JNull:
    for jsonMsg in jsonObj["collectibles"]:
      result.collectibles.add(jsonMsg.toProfileShowcaseCollectible())
  if jsonObj["verifiedTokens"].kind != JNull:
    for jsonMsg in jsonObj["verifiedTokens"]:
      result.verifiedTokens.add(jsonMsg.toProfileShowcaseVerifiedToken())
  if jsonObj["unverifiedTokens"].kind != JNull:
    for jsonMsg in jsonObj["unverifiedTokens"]:
      result.unverifiedTokens.add(jsonMsg.toProfileShowcaseUnverifiedToken())

proc `%`*(x: ProfileShowcaseAccount): JsonNode =
  result = newJobject()
  result["contactId"] = % x.contactId
  result["address"] = % x.address
  result["name"] = % x.name
  result["colorId"] = % x.colorId
  result["emoji"] = % x.emoji
  result["order"] = % x.order
