import sugar, sequtils, Tables
import io_interface
import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../../app_service/service/network/service as network_service
import ../../../../../app_service/service/token/service as token_service
import ../../../../../app_service/service/currency/service as currency_service
import ../../../../../app_service/service/collectible/service as collectible_service

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    walletAccountService: wallet_account_service.Service
    networkService: network_service.Service
    tokenService: token_service.Service
    currencyService: currency_service.Service
    collectibleService: collectible_service.Service
 
proc newController*(
  delegate: io_interface.AccessInterface,
  walletAccountService: wallet_account_service.Service,
  networkService: network_service.Service,
  tokenService: token_service.Service,
  currencyService: currency_service.Service,
  collectibleService: collectible_service.Service,
): Controller =
  result = Controller()
  result.delegate = delegate
  result.walletAccountService = walletAccountService
  result.networkService = networkService
  result.tokenService = tokenService
  result.currencyService = currencyService
  result.collectibleService = collectibleService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  discard

proc getWalletAccount*(self: Controller, accountIndex: int): wallet_account_service.WalletAccountDto =
  return self.walletAccountService.getWalletAccount(accountIndex)

proc update*(self: Controller, address: string, accountName: string, color: string, emoji: string) =
  discard self.walletAccountService.updateWalletAccount(address, accountName, color, emoji)

method findTokenSymbolByAddress*(self: Controller, address: string): string =
  return self.walletAccountService.findTokenSymbolByAddress(address)

proc getChainIds*(self: Controller): seq[int] = 
  return self.networkService.getNetworks().map(n => n.chainId)

proc getEnabledChainIds*(self: Controller): seq[int] = 
  return self.networkService.getNetworks().filter(n => n.enabled).map(n => n.chainId)

proc getCurrentCurrency*(self: Controller): string =
  return self.walletAccountService.getCurrency()

proc getCurrencyFormat*(self: Controller, symbol: string): CurrencyFormatDto =
  return self.currencyService.getCurrencyFormat(symbol)

proc getAllMigratedKeyPairs*(self: Controller): seq[KeyPairDto] =
  return self.walletAccountService.getAllMigratedKeyPairs()

proc getHasCollectiblesCache*(self: Controller, address: string): bool  =
  return self.collectibleService.areCollectionsLoaded(address)