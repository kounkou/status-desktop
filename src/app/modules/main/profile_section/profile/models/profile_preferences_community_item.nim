import json, strutils, stint, json_serialization, tables

import profile_preferences_base_item

import app_service/service/profile/dto/profile_showcase_entry
import app_service/service/community/dto/community

include app_service/common/json_utils
include app_service/common/utils

type
  ProfileShowcaseCommunityItem* = ref object of ProfileShowcaseBaseItem
    id*: string
    name*: string
    memberRole*: MemberRole
    image*: string
    color*: string

proc initProfileShowcaseCommunityItem*(community: CommunityDto, entry: ProfileShowcaseEntryDto): ProfileShowcaseCommunityItem =
  result = ProfileShowcaseCommunityItem()

  result.showcaseVisibility = entry.showcaseVisibility
  result.order = entry.order

  result.id = community.id
  result.name = community.name
  result.memberRole = community.memberRole
  result.image = community.images.thumbnail
  result.color = community.color

proc toProfileShowcaseCommunityItem*(jsonObj: JsonNode): ProfileShowcaseCommunityItem =
  result = ProfileShowcaseCommunityItem()

  discard jsonObj.getProp("order", result.order)
  var visibilityInt: int
  if (jsonObj.getProp("showcaseVisibility", visibilityInt) and
    (visibilityInt >= ord(low(ProfileShowcaseVisibility)) and
    visibilityInt <= ord(high(ProfileShowcaseVisibility)))):
      result.showcaseVisibility = ProfileShowcaseVisibility(visibilityInt)

  discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("memberRole", result.memberRole)
  discard jsonObj.getProp("image", result.image)
  discard jsonObj.getProp("color", result.color)

proc getEntryDto*(self: ProfileShowcaseCommunityItem): ProfileShowcaseEntryDto =
  result = ProfileShowcaseEntryDto()

  result.id = self.id
  result.entryType = ProfileShowcaseEntryType.Community
  result.showcaseVisibility = self.showcaseVisibility
  result.order = self.order

proc name*(self: ProfileShowcaseCommunityItem): string {.inline.} =
  self.name

proc memberRole*(self: ProfileShowcaseCommunityItem): MemberRole {.inline.} =
  self.memberRole

proc image*(self: ProfileShowcaseCommunityItem): string {.inline.} =
  self.image

proc color*(self: ProfileShowcaseCommunityItem): string {.inline.} =
  self.color