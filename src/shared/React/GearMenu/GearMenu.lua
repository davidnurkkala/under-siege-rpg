local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Aspect = require(ReplicatedStorage.Shared.React.Common.Aspect)
local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local GridLayout = require(ReplicatedStorage.Shared.React.Common.GridLayout)
local HeightText = require(ReplicatedStorage.Shared.React.Common.HeightText)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local LayoutContainer = require(ReplicatedStorage.Shared.React.Common.LayoutContainer)
local ListLayout = require(ReplicatedStorage.Shared.React.Common.ListLayout)
local PaddingAll = require(ReplicatedStorage.Shared.React.Common.PaddingAll)
local Panel = require(ReplicatedStorage.Shared.React.Common.Panel)
local RatioText = require(ReplicatedStorage.Shared.React.Common.RatioText)
local React = require(ReplicatedStorage.Packages.React)
local RewardDisplayHelper = require(ReplicatedStorage.Shared.Util.RewardDisplayHelper)
local ScrollingFrame = require(ReplicatedStorage.Shared.React.Common.ScrollingFrame)
local Sift = require(ReplicatedStorage.Packages.Sift)
local SystemWindow = require(ReplicatedStorage.Shared.React.Common.SystemWindow)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)
local TryNow = require(ReplicatedStorage.Shared.Util.TryNow)
local UseWeapons = require(ReplicatedStorage.Shared.React.Hooks.UseWeapons)
local WeaponController = require(ReplicatedStorage.Shared.Controllers.WeaponController)

local function itemDetails(props: {
	Item: any,
	Close: () -> (),
	Equip: () -> (),
	Equipped: boolean,
})
	local textRatio = 1 / 15
	local item = props.Item

	local description = RewardDisplayHelper.GetRewardDetails(item)

	return React.createElement(React.Fragment, nil, {
		Left = React.createElement(Container, {
			Size = UDim2.fromScale(0.25, 1),
		}, {
			Layout = React.createElement(ListLayout, {
				Padding = UDim.new(0, 4),
			}),

			PreviewPanel = React.createElement(Panel, {
				LayoutOrder = 1,
				Size = UDim2.fromScale(1, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeXX,
				ImageColor3 = RewardDisplayHelper.GetRewardColor(item),
			}, {
				Preview = RewardDisplayHelper.CreateRewardElement(item),
			}),
		}),

		Description = React.createElement(Container, {
			Size = UDim2.fromScale(0.75, 0.9),
			Position = UDim2.fromScale(0.25, 0),
		}, {
			Padding = React.createElement(PaddingAll, {
				Padding = UDim.new(0.05, 0),
			}),

			ScrollingFrame = React.createElement(ScrollingFrame, {
				ScrollingDirection = Enum.ScrollingDirection.Y,
				ScrollBarThickness = 8,
				ScrollBarImageColor3 = ColorDefs.Blue,
				RenderLayout = function(setCanvasSize)
					return React.createElement(ListLayout, {
						Padding = UDim.new(0, 6),
						[React.Change.AbsoluteContentSize] = function(object)
							setCanvasSize(UDim2.fromOffset(0, object.AbsoluteContentSize.Y + 4))
						end,
					})
				end,
			}, {
				Padding = React.createElement("UIPadding", {
					PaddingRight = UDim.new(0, 12),
					PaddingLeft = UDim.new(0, 2),
				}),

				Text = React.createElement(RatioText, {
					LayoutOrder = 1,
					Ratio = textRatio,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					Text = TextStroke(description),
				}),
			}),
		}),

		Buttons = React.createElement(Container, {
			Size = UDim2.fromScale(0.7, 0.1),
			Position = UDim2.fromScale(1, 1),
			AnchorPoint = Vector2.new(1, 1),
		}, {
			Layout = React.createElement(ListLayout, {
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 12),
			}),

			Back = React.createElement(Button, {
				LayoutOrder = -1,
				Size = UDim2.fromScale(0.3, 1),
				[React.Event.Activated] = props.Close,
			}, {
				Text = React.createElement(Label, {
					Text = TextStroke("Back"),
				}),
			}),

			Equip = React.createElement(Button, {
				LayoutOrder = -3,
				Size = UDim2.fromScale(0.3, 1),
				[React.Event.Activated] = props.Equip,
				Active = not props.Equipped,
				ImageColor3 = if props.Equipped then ColorDefs.Gray50 else ColorDefs.LightBlue,
			}, {
				Text = React.createElement(Label, {
					Text = TextStroke(if props.Equipped then "Equipped" else "Equip"),
				}),
			}),
		}),
	})
end

local function categoryButton(props: {
	Text: string,
	Color: Color3,
	Activate: () -> (),
	Active: boolean,
})
	return React.createElement(LayoutContainer, {
		Size = UDim2.fromScale(0, 1),
		AutomaticSize = Enum.AutomaticSize.X,
		Padding = 6,
	}, {
		Button = React.createElement(Button, {
			Size = UDim2.fromScale(0, 1),
			AutomaticSize = Enum.AutomaticSize.X,
			ImageColor3 = if props.Active then props.Color else ColorDefs.Gray75,
			Active = props.Active,
			[React.Event.Activated] = props.Activate,
		}, {
			Label = React.createElement(HeightText, {
				Size = UDim2.fromScale(0, 1),
				AutomaticSize = Enum.AutomaticSize.X,
				Text = props.Text,
			}),
		}),
	})
end

return function(props: {
	Visible: boolean,
	Close: () -> (),
})
	local category, setCategory = React.useState("Weapons")
	local state, setState = React.useState("Inventory")
	local selectedItem, setSelectedItem = React.useState(nil)

	local weapons = UseWeapons()

	local items = {}
	if category == "Weapons" then
		items = TryNow(function()
			return Sift.Array.map(Sift.Array.sort(Sift.Dictionary.keys(weapons.Owned)), function(weaponId)
				return {
					Type = "Weapon",
					WeaponId = weaponId,
					Equipped = weapons.Equipped == weaponId,
				}
			end)
		end, {})
	end

	local getIsEquipped = React.useCallback(function(item)
		return TryNow(function()
			if category == "Weapons" then
				return weapons.Equipped == item.WeaponId
			else
				return false
			end
		end, false)
	end, { category, weapons })

	return React.createElement(SystemWindow, {
		Visible = props.Visible,
		HeaderText = TextStroke("Gear"),
		[React.Event.Activated] = props.Close,
		RatioDisabled = true,
		Size = UDim2.fromScale(1.2, 0.8),
		HeaderSize = 0.075,
	}, {
		Details = (state == "Details") and React.createElement(itemDetails, {
			Item = selectedItem,
			Equipped = getIsEquipped(selectedItem),
			Close = function()
				setSelectedItem(nil)
				setState("Inventory")
			end,
			Equip = function()
				if category == "Weapons" then WeaponController:EquipWeapon(selectedItem.WeaponId) end
			end,
		}),

		Inventory = React.createElement(Container, {
			Visible = state == "Inventory",
		}, {
			CategoryButtons = React.createElement(Container, {
				Size = UDim2.fromScale(1, 0.15),
			}, {
				Layout = React.createElement(ListLayout, {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = UDim.new(0, 4),
				}),

				Weapons = React.createElement(categoryButton, {
					Text = "Weapons",
					Color = ColorDefs.LightRed,
					Activate = function()
						setCategory("Weapons")
					end,
					Active = category ~= "Weapons",
				}),

				Bases = React.createElement(categoryButton, {
					Text = "Bases",
					Color = ColorDefs.LightPurple,
					Activate = function()
						setCategory("Bases")
					end,
					Active = category ~= "Bases",
				}),
			}),

			Items = React.createElement(ScrollingFrame, {
				Size = UDim2.fromScale(1, 0.85),
				Position = UDim2.fromScale(0, 0.15),
				RenderLayout = function(setCanvasSize)
					return React.createElement(GridLayout, {
						CellSize = UDim2.fromScale(0.5, 1),
						[React.Change.AbsoluteContentSize] = function(object)
							setCanvasSize(UDim2.fromOffset(0, object.AbsoluteContentSize.Y))
						end,
					}, {
						Ratio = React.createElement(Aspect, {
							AspectRatio = 4.5,
						}),
					})
				end,
			}, {
				Panels = React.createElement(
					React.Fragment,
					nil,
					Sift.Array.map(items, function(item, index)
						return React.createElement(LayoutContainer, {
							Padding = 8,
							LayoutOrder = index,
						}, {
							Panel = React.createElement(Panel, {
								ImageColor3 = ColorDefs.PaleRed,
							}, {
								Left = React.createElement(Container, nil, {
									Layout = React.createElement(ListLayout, {
										FillDirection = Enum.FillDirection.Horizontal,
										Padding = UDim.new(0, 6),
									}),

									PreviewContainer = React.createElement(Panel, {
										LayoutOrder = 1,
										Size = UDim2.fromScale(1, 1),
										SizeConstraint = Enum.SizeConstraint.RelativeYY,
										ImageColor3 = RewardDisplayHelper.GetRewardColor(item),
									}, {
										Preview = RewardDisplayHelper.CreateRewardElement(item),
									}),

									Right = React.createElement(Container, {
										LayoutOrder = 2,
										Size = UDim2.fromScale(0, 1),
										AutomaticSize = Enum.AutomaticSize.X,
									}, {
										Layout = React.createElement(ListLayout, {
											VerticalAlignment = Enum.VerticalAlignment.Center,
										}),

										Name = React.createElement(HeightText, {
											LayoutOrder = 1,
											Size = UDim2.fromScale(0, 1 / 3),
											Text = TextStroke(RewardDisplayHelper.GetRewardText(item, true)),
											TextXAlignment = Enum.TextXAlignment.Left,
											AutomaticSize = Enum.AutomaticSize.X,
										}),

										Equipped = getIsEquipped(item) and React.createElement(HeightText, {
											LayoutOrder = 2,
											Size = UDim2.fromScale(0, 1 / 3),
											Text = TextStroke("Equipped"),
											TextXAlignment = Enum.TextXAlignment.Left,
											AutomaticSize = Enum.AutomaticSize.X,
										}),
									}),
								}),

								Button = React.createElement(LayoutContainer, {
									Padding = 5,
									Size = UDim2.fromScale(0.25, 1),
									AnchorPoint = Vector2.new(1, 0),
									Position = UDim2.fromScale(1, 0),
								}, {
									Button = React.createElement(Button, {
										ImageColor3 = ColorDefs.DarkRed,
										BorderSizePixel = 2,
										[React.Event.Activated] = function()
											setSelectedItem(item)
											setState("Details")
										end,
									}, {
										Label = React.createElement(Label, {
											Text = "Select",
										}),
									}),
								}),
							}),
						})
					end)
				),
			}),
		}),
	})
end
