local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local GuideController = require(ReplicatedStorage.Shared.Controllers.GuideController)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Panel = require(ReplicatedStorage.Shared.React.Common.Panel)
local PlatformContext = require(ReplicatedStorage.Shared.React.PlatformContext.PlatformContext)
local Property = require(ReplicatedStorage.Shared.Classes.Property)
local React = require(ReplicatedStorage.Packages.React)
local Sift = require(ReplicatedStorage.Packages.Sift)
local SliceArrow = require(ReplicatedStorage.Shared.React.Common.SliceArrow)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)
local Trove = require(ReplicatedStorage.Packages.Trove)
local UseIsMobile = require(ReplicatedStorage.Shared.React.Hooks.UseIsMobile)

local function guide(props: {
	Args: any,
	Gui: GuiObject,
})
	local isMobile = UseIsMobile()

	local offset: Vector2 = props.Args.Offset * if isMobile then 2 / 3 else 1
	local direction = offset.Unit
	local text: string = props.Args.Text
	local anchor: Vector2 = props.Args.Anchor

	local position, setPosition = React.useBinding(UDim2.new())

	React.useEffect(function()
		return Observers.observeProperty(props.Gui, "AbsolutePosition", function(absolutePosition)
			return Observers.observeProperty(props.Gui, "AbsoluteSize", function(absoluteSize)
				local p = absolutePosition + (absoluteSize * anchor) + offset + Vector2.new(0, GuiService:GetGuiInset().Y)
				setPosition(UDim2.fromOffset(p.X, p.Y))
			end)
		end)
	end, { offset, props.Gui })

	return React.createElement(Container, {
		Size = UDim2.fromScale(0.2, 0.2 / 3),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = position:map(function(value)
			return value
		end),
	}, {
		Panel = React.createElement(Panel, {
			ZIndex = 4,
		}, {
			Label = React.createElement(Label, {
				Text = TextStroke(text),
			}),
		}),

		Arrow = React.createElement(SliceArrow, {
			Size = UDim2.fromOffset(56, offset.Magnitude),
			Position = UDim2.new(0.5, -offset.X / 2, 0.5, -offset.Y / 2),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Rotation = math.deg(math.atan2(direction.Y, direction.X)) - 90,
		}),
	})
end

return function()
	local guides, setGuides = React.useState({})

	React.useEffect(function()
		local trove = Trove.new()

		local guiGuideProp = trove:Construct(Property, {}, Sift.Dictionary.equalsDeep)
		guiGuideProp:Observe(function(guiGuide)
			local innerTrove = Trove.new()

			for tag, args in guiGuide do
				innerTrove:Add(Observers.observeTag(tag, function(gui)
					setGuides(function(oldGuides)
						return Sift.Dictionary.set(oldGuides, tag, {
							Args = args,
							Gui = gui,
						})
					end)

					return function()
						setGuides(function(oldGuides)
							return Sift.Dictionary.removeKey(oldGuides, tag)
						end)
					end
				end, { Players.LocalPlayer }))
			end

			return function()
				innerTrove:Clean()
			end
		end)

		trove:Add(GuideController.GuiGuideRemote:Observe(function(guiGuide)
			guiGuideProp:Set(guiGuide)
		end))

		return function()
			trove:Clean()
		end
	end, {})

	return React.createElement(
		Container,
		{ ZIndex = 4192 },
		Sift.Dictionary.map(guides, function(data)
			return React.createElement(guide, {
				Args = data.Args,
				Gui = data.Gui,
			})
		end)
	)
end
