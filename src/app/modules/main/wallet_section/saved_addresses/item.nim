import strformat

import app_service/common/account_constants

type
  Item* = object
    name: string
    address: string
    ens: string
    colorId: string
    chainShortNames: string
    isTest: bool

proc initItem*(
  name: string,
  address: string,
  ens: string,
  colorId: string,
  chainShortNames: string,
  isTest: bool
): Item =
  result.name = name
  result.address = address
  result.ens = ens
  result.colorId = colorId
  result.chainShortNames = chainShortNames
  result.isTest = isTest

proc `$`*(self: Item): string =
  result = fmt"""SavedAddressItem(
    name: {self.name},
    address: {self.address},
    ens: {self.ens},
    colorId: {self.colorId},
    chainShortNames: {self.chainShortNames},
    isTest: {self.isTest},
    ]"""

proc isEmpty*(self: Item): bool =
  return (self.address.len == 0 or self.address == ZERO_ADDRESS) and self.ens.len == 0

proc getName*(self: Item): string =
  return self.name

proc getEns*(self: Item): string =
  return self.ens

proc getAddress*(self: Item): string =
  return self.address

proc getColorId*(self: Item): string =
  return self.colorId

proc getChainShortNames*(self: Item): string =
  return self.chainShortNames

proc getIsTest*(self: Item): bool =
  return self.isTest
