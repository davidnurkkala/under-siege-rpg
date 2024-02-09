local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local AbilityDefs = require(ReplicatedStorage.Shared.Defs.AbilityDefs)
local BattleController = require(ReplicatedStorage.Shared.Controllers.BattleController)
local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local CardDefs = require(ReplicatedStorage.Shared.Defs.CardDefs)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local ComponentController = require(ReplicatedStorage.Shared.Controllers.ComponentController)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local Flipper = require(ReplicatedStorage.Packages.Flipper)
local Frame = require(ReplicatedStorage.Shared.React.Common.Frame)
local GoonHealthBar = require(ReplicatedStorage.Shared.React.Battle.GoonHealthBar)
local GoonPreview = require(ReplicatedStorage.Shared.React.Goons.GoonPreview)
local HealthBar = require(ReplicatedStorage.Shared.React.Battle.HealthBar)
local Image = require(ReplicatedStorage.Shared.React.Common.Image)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local LayoutContainer = require(ReplicatedStorage.Shared.React.Common.LayoutContainer)
local ListLayout = require(ReplicatedStorage.Shared.React.Common.ListLayout)
local Observers = require(ReplicatedStorage.Packages.Observers)
local PlatformContext = require(ReplicatedStorage.Shared.React.PlatformContext.PlatformContext)
local PrimaryButton = require(ReplicatedStorage.Shared.React.Common.PrimaryButton)
local Promise = require(ReplicatedStorage.Packages.Promise)
local PromiseMotor = require(ReplicatedStorage.Shared.Util.PromiseMotor)
local PromptWindow = require(ReplicatedStorage.Shared.React.Common.PromptWindow)
local React = require(ReplicatedStorage.Packages.React)
local RoundButtonWithImage = require(ReplicatedStorage.Shared.React.Common.RoundButtonWithImage)
local Sift = require(ReplicatedStorage.Packages.Sift)
local SliceArrow = require(ReplicatedStorage.Shared.React.Common.SliceArrow)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)
local Trove = require(ReplicatedStorage.Packages.Trove)
local TryNow = require(ReplicatedStorage.Shared.Util.TryNow)
local UseMotor = require(ReplicatedStorage.Shared.React.Hooks.UseMotor)

local function getHealthPercent(status, index)
	return TryNow(function()
		local battler = status.Battlers[index]
		return battler.Health / battler.HealthMax
	end, 1)
end

local function goonHealthBar(props: {
	GoonModel: any,
})
	local percent, setPercent = React.useState(1)
	local level, setLevel = React.useState(0)

	React.useEffect(function()
		local trove = Trove.new()

		local health = props.GoonModel.Health
		trove:Add(health:Observe(function()
			setPercent(health:GetPercent())
		end))

		trove:Add(Observers.observeAttribute(props.GoonModel.Root, "Level", setLevel))

		return function()
			trove:Clean()
		end
	end, { props.GoonModel })

	if percent <= 0 then return end

	return React.createElement(GoonHealthBar, {
		Adornee = props.GoonModel.OverheadPoint,
		Level = level,
		Percent = percent,
	})
end

local function broadcast(props: {
	Message: string?,
	Finish: () -> (),
})
	local chars, charsMotor = UseMotor(0)

	React.useEffect(function()
		charsMotor:setGoal(Flipper.Instant.new(0))
		charsMotor:step()

		if not props.Message then return end

		local count = 0
		for _ in utf8.graphemes(props.Message) do
			count += 1
		end

		local promise = PromiseMotor(charsMotor, Flipper.Spring.new(count, { frequency = 2 }), function(value)
			return math.abs(value - count) < 0.1
		end):andThenCall(Promise.delay, 3):andThenCall(props.Finish)

		return function()
			promise:cancel()
		end
	end, { props.Message, props.Finish })

	return props.Message
		and React.createElement(Label, {
			Text = TextStroke(props.Message),
			MaxVisibleGraphemes = chars:map(function(value)
				return math.round(value)
			end),
			Size = UDim2.fromScale(1, 0.1),
			Position = UDim2.fromScale(0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0),
		})
end

local function suppliesContent(props: {
	Status: any,
})
	local supplies, setSupplies = React.useState(0)
	local gain, setGain = React.useState(0)

	React.useEffect(function()
		TryNow(function()
			local battler = props.Status.Battlers[1]
			setSupplies(battler.Supplies)
			setGain(battler.SuppliesGain)
		end)
	end, { props.Status })

	return React.createElement(React.Fragment, nil, {
		Label = React.createElement(Label, {
			Text = TextStroke(`Supplies`),
			TextXAlignment = Enum.TextXAlignment.Center,
			Size = UDim2.fromScale(0.7, 0.5),
			Position = UDim2.fromScale(0.3, 0),
		}),
		Icon = React.createElement(Image, {
			Image = CurrencyDefs.Supplies.Image,
			Size = UDim2.fromScale(0.25, 0.5),
		}),
		Current = React.createElement(Label, {
			Text = TextStroke(supplies),
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.fromScale(0.45, 0.5),
			Position = UDim2.fromScale(0, 1),
			AnchorPoint = Vector2.new(0, 1),
		}),
		Gain = React.createElement(Label, {
			Text = TextStroke(`(+{gain})`),
			TextXAlignment = Enum.TextXAlignment.Right,
			Size = UDim2.fromScale(0.45, 0.5),
			Position = UDim2.fromScale(1, 1),
			AnchorPoint = Vector2.new(1, 1),
		}),
	})
end

local function cooldownBar(props: {
	Time: number,
	TimeMax: number,
})
	local ratio, ratioMotor = UseMotor(0)

	React.useEffect(function()
		local r = math.clamp(1 - (props.Time - 0.5) / props.TimeMax, 0, 1)
		local velocity = 1 / props.TimeMax

		ratioMotor:setGoal(Flipper.Linear.new(r, { velocity = velocity }))
	end, { props.Time, props.TimeMax })

	return React.createElement(Frame, {
		ZIndex = 64,
		Size = ratio:map(function(value)
			return UDim2.fromScale(1, value)
		end),
		BackgroundColor3 = ColorDefs.White,
		BackgroundTransparency = 0.5,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.fromScale(0, 1),
	})
end

local function attackButton(props: {
	Status: any,
	LayoutOrder: number,
})
	local platform = React.useContext(PlatformContext)
	local cooldown, setCooldown = React.useState(nil)

	React.useEffect(function()
		if not props.Status then return end

		setCooldown(props.Status.Battlers[1].AttackCooldown)
	end, { props.Status })

	local onCooldown = (cooldown ~= nil) and (cooldown.Time > 0)

	return React.createElement(Container, {
		[React.Tag] = "GuiBattleAttackButton",
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		LayoutOrder = props.LayoutOrder,
	}, {
		Button = React.createElement(PrimaryButton, {
			Active = not onCooldown,
			Selectable = false,
		}, {
			Icon = React.createElement(Image, {
				Image = "rbxassetid://15243978990",
			}),

			CooldownBar = onCooldown and React.createElement(cooldownBar, cooldown),

			GamepadHint = React.createElement(RoundButtonWithImage, {
				Visible = platform == "Console",
				Image = UserInputService:GetImageForKeyCode(Enum.KeyCode.ButtonR2),
				Text = "Shoot",
				Selectable = false,
				Position = UDim2.new(0.5, 0, 0, -4),
				AnchorPoint = Vector2.new(0.5, 1),
				height = UDim.new(0.4, 0),
			}),
		}),
	})
end

local function upgradeButton(props: {
	Status: any,
})
	local battler = props.Status and props.Status.Battlers[1]

	return (battler ~= nil)
		and React.createElement(Button, {
			ImageColor3 = if battler.Supplies > battler.SuppliesUpgradeCost then ColorDefs.PaleGreen else ColorDefs.PaleRed,
			[React.Event.Activated] = function()
				BattleController.SuppliesUpgraded:Fire()
			end,
		}, {
			Image = React.createElement(Image, {
				Image = CurrencyDefs.Supplies.Image,
				Size = UDim2.fromScale(0.75, 0.75),
				Position = UDim2.fromScale(0, 1),
				AnchorPoint = Vector2.new(0, 1),
			}),
			Arrow = React.createElement(Image, {
				Image = "rbxassetid://15548681925",
				ZIndex = 4,
				Size = UDim2.fromScale(0.75, 0.75),
				Position = UDim2.fromScale(1, 0),
				AnchorPoint = Vector2.new(1, 0),
			}),
			Cost = React.createElement(Label, {
				ZIndex = 16,
				Size = UDim2.fromScale(1, 0.5),
				Position = UDim2.fromScale(0, 0.5),
				Text = TextStroke(tostring(battler.SuppliesUpgradeCost)),
				TextXAlignment = Enum.TextXAlignment.Right,
			}),
		})
end

local function hotbar(props: {
	Status: any,
	FirstCardRef: any,
})
	local cooldowns, setCooldowns = React.useState({})
	local supplies, setSupplies = React.useState(0)

	React.useEffect(function()
		if not props.Status then return end

		setCooldowns(props.Status.Battlers[1].DeckCooldowns)
		setSupplies(props.Status.Battlers[1].Supplies)
	end, { props.Status })

	return React.createElement(React.Fragment, nil, {
		Layout = React.createElement(ListLayout, {
			FillDirection = Enum.FillDirection.Horizontal,
		}),

		Buttons = React.createElement(
			React.Fragment,
			nil,
			Sift.Dictionary.map(
				Sift.Array.sort(Sift.Dictionary.keys(cooldowns), function(a, b)
					local defA, defB = CardDefs[a], CardDefs[b]
					if defA.Cost == defB.Cost then
						return defA.Name < defB.Name
					else
						return defA.Cost < defB.Cost
					end
				end),
				function(cardId, index)
					local cooldown = cooldowns[cardId]
					local def = CardDefs[cardId]

					local canAfford = supplies >= def.Cost
					local onCooldown = cooldown.Time > 0

					local color = if canAfford then ColorDefs.PaleGreen else ColorDefs.PaleRed
					if onCooldown then color = color:Lerp(ColorDefs.Gray25, 0.5) end

					return React.createElement(LayoutContainer, {
						LayoutOrder = index,
						Size = UDim2.fromScale(1, 1),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						Padding = 6,
					}, {
						Button = React.createElement(Button, {
							[React.Tag] = `GuiBattleDeckButton{index}`,
							ImageColor3 = color,
							Active = canAfford and not onCooldown,
							BorderColor3 = if onCooldown then ColorDefs.PaleBlue else nil,
							BorderSizePixel = if onCooldown then 1 else nil,
							[React.Event.Activated] = function()
								BattleController.CardPlayed:Fire(cardId)
							end,

							buttonRef = if index == 1 then props.FirstCardRef else nil,
						}, {
							Image = if def.Type == "Goon"
								then React.createElement(GoonPreview, {
									GoonId = def.GoonId,
								})
								else React.createElement(Image, {
									Image = AbilityDefs[def.AbilityId].Image,
								}),

							Cost = React.createElement(Label, {
								Text = TextStroke(def.Cost),
								TextXAlignment = Enum.TextXAlignment.Right,
								TextYAlignment = Enum.TextYAlignment.Bottom,
								Size = UDim2.fromScale(0.5, 0.5),
								AnchorPoint = Vector2.new(1, 1),
								Position = UDim2.fromScale(1, 1),
								ZIndex = 8,
							}),

							Bar = onCooldown and React.createElement(cooldownBar, {
								Time = cooldown.Time,
								TimeMax = cooldown.TimeMax,
							}),
						}),
					}),
						cardId
				end
			)
		),
	})
end

return function(props: {
	Visible: boolean,
})
	local status, setStatus = React.useState(nil)
	local goonModels, setGoonModels = React.useState({})
	local surrendering, setSurrendering = React.useState(false)
	local message, setMessage = React.useState(nil)
	local platform = React.useContext(PlatformContext)
	local firstCardRef = React.useRef(nil)

	local clearMessage = React.useCallback(function()
		setMessage(nil)
	end, { setMessage })

	React.useEffect(function()
		if not props.Visible then return end
		if surrendering then return end

		if platform == "Console" then GuiService.SelectedObject = firstCardRef.current end

		ContextActionService:BindActionAtPriority("SelectSurrender", function(_, inputState)
			if inputState ~= Enum.UserInputState.Begin then return Enum.ContextActionResult.Pass end

			setSurrendering(true)
			return Enum.ContextActionResult.Sink
		end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.ButtonSelect)

		return function()
			ContextActionService:UnbindAction("SelectSurrender")
		end
	end, { props.Visible, surrendering, firstCardRef.current })

	React.useEffect(function()
		if not props.Visible then return end

		return BattleController:ObserveStatus(setStatus)
	end, { props.Visible })

	React.useEffect(function()
		if not props.Visible then return end

		local function update()
			setGoonModels(Sift.Dictionary.map(ComponentController:GetComponentsByName("GoonModel"), function(goonModel)
				return goonModel, goonModel.Guid
			end))
		end

		local stopObserving = ComponentController:ObserveClass("GoonModel", function()
			update()
			return update
		end)

		return function()
			stopObserving()
			setGoonModels({})
		end
	end, { props.Visible })

	React.useEffect(function()
		if not props.Visible then return end

		local trove = Trove.new()

		trove:Connect(BattleController.MessageSent, function(messageIn)
			setMessage(messageIn)
		end)

		return function()
			trove:Clean()
		end
	end, { props.Visible })

	return React.createElement(Container, {
		Visible = props.Visible,
	}, {
		Padding = React.createElement("UIPadding", {
			PaddingLeft = UDim.new(0.05, 0),
			PaddingRight = UDim.new(0.05, 0),
			PaddingTop = UDim.new(0.05, 0),
			PaddingBottom = UDim.new(0.01, 0),
		}),

		GoonHealthBars = React.createElement(
			"Folder",
			nil,
			Sift.Dictionary.map(goonModels, function(goonModel)
				return React.createElement(goonHealthBar, {
					GoonModel = goonModel,
				})
			end)
		),

		Message = React.createElement(broadcast, {
			Message = message,
			Finish = clearMessage,
		}),

		HealthBars = (status and status.Battlers) and React.createElement(React.Fragment, nil, {
			HealthBarLeft = React.createElement("BillboardGui", {
				Size = UDim2.fromScale(8, 1),
				AlwaysOnTop = true,
				Adornee = TryNow(function()
					return status.Battlers[1].CharModel
				end),
				ExtentsOffsetWorldSpace = Vector3.new(0, 2, 0),
			}, {
				Bar = React.createElement(HealthBar, {
					Alignment = Enum.HorizontalAlignment.Left,
					Percent = getHealthPercent(status, 1),
				}),
			}),

			HealthBarRight = React.createElement("BillboardGui", {
				Size = UDim2.fromScale(8, 1),
				AlwaysOnTop = true,
				Adornee = TryNow(function()
					return status.Battlers[2].CharModel
				end),
				ExtentsOffsetWorldSpace = Vector3.new(0, 2, 0),
			}, {
				Bar = React.createElement(HealthBar, {
					Alignment = Enum.HorizontalAlignment.Right,
					Percent = getHealthPercent(status, 2),
				}),
			}),
		}),

		Bottom = React.createElement(Container, nil, {
			Layout = React.createElement(ListLayout, {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
				Padding = UDim.new(0, 6),
			}),

			Hotbar = React.createElement(Container, {
				LayoutOrder = 2,
				Size = UDim2.fromScale(1, 0.1),
				SizeConstraint = Enum.SizeConstraint.RelativeXX,
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.fromScale(0.5, 1),
			}, {
				Hotbar = React.createElement(hotbar, {
					Status = status,
					FirstCardRef = firstCardRef,
				}),
			}),

			Buttons = React.createElement(Container, {
				LayoutOrder = 1,
				Size = UDim2.fromScale(1, 0.075),
				SizeConstraint = Enum.SizeConstraint.RelativeXX,
			}, {
				Left = React.createElement(Container, nil, {
					Layout = React.createElement(ListLayout, {
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						VerticalAlignment = Enum.VerticalAlignment.Bottom,
						Padding = UDim.new(0, 16),
					}),

					AttackButton = React.createElement(attackButton, {
						Status = status,
						LayoutOrder = 1,
					}),

					Supplies = React.createElement(Container, {
						LayoutOrder = 2,
						Size = UDim2.fromScale(1.75, 1),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
					}, {
						Content = React.createElement(suppliesContent, {
							Status = status,
						}),
					}),

					Upgrade = React.createElement(Container, {
						LayoutOrder = 3,
						Size = UDim2.fromScale(0.75, 0.75),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
					}, {
						Content = React.createElement(upgradeButton, {
							Status = status,
						}),
					}),
				}),

				Right = React.createElement(Container, nil, {
					Layout = React.createElement(ListLayout, {
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Right,
						VerticalAlignment = Enum.VerticalAlignment.Bottom,
						Padding = UDim.new(0, 8),
					}),

					Surrender = React.createElement(Button, {
						LayoutOrder = 1,
						Visible = not surrendering,
						Size = UDim2.fromScale(0.75, 0.75),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						ImageColor3 = ColorDefs.PaleGreen,
						BorderColor3 = ColorDefs.LightGreen,
						[React.Event.Activated] = function()
							setSurrendering(true)
						end,
						Selectable = false,
					}, {
						Image = React.createElement(Image, {
							Image = "rbxassetid://15484464238",
						}),
						GamepadHint = React.createElement(RoundButtonWithImage, {
							Visible = platform == "Console",
							Image = UserInputService:GetImageForKeyCode(Enum.KeyCode.ButtonSelect),
							Text = "Surrender",
							Selectable = false,
							Position = UDim2.new(0.5, 0, 0, -4),
							AnchorPoint = Vector2.new(0.5, 1),
							height = UDim.new(0.4, 0),
						}),
					}),
				}),
			}),
		}),

		SurrenderPrompt = React.createElement(PromptWindow, {
			Visible = surrendering,

			HeaderText = TextStroke("Surrender"),
			Text = TextStroke("Are you sure you want to surrender?"),
			Options = {
				{
					Text = TextStroke("Yes"),
					Select = function()
						setSurrendering(false)
						BattleController.SurrenderRequested:Fire()
					end,
				},
				{
					Text = TextStroke("No"),
					Select = function()
						setSurrendering(false)
					end,
				},
			},
			[React.Event.Activated] = function()
				setSurrendering(false)
			end,
		}),
	})
end
