local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local DeckHelper = require(ReplicatedStorage.Shared.Util.DeckHelper)
local Flipper = require(ReplicatedStorage.Packages.Flipper)
local GenericShopController = require(ReplicatedStorage.Shared.Controllers.GenericShopController)
local HeightText = require(ReplicatedStorage.Shared.React.Common.HeightText)
local Image = require(ReplicatedStorage.Shared.React.Common.Image)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local LayoutContainer = require(ReplicatedStorage.Shared.React.Common.LayoutContainer)
local ListLayout = require(ReplicatedStorage.Shared.React.Common.ListLayout)
local PaddingAll = require(ReplicatedStorage.Shared.React.Common.PaddingAll)
local Panel = require(ReplicatedStorage.Shared.React.Common.Panel)
local PromiseMotor = require(ReplicatedStorage.Shared.Util.PromiseMotor)
local RatioText = require(ReplicatedStorage.Shared.React.Common.RatioText)
local React = require(ReplicatedStorage.Packages.React)
local RewardDisplayHelper = require(ReplicatedStorage.Shared.Util.RewardDisplayHelper)
local ScrollingFrame = require(ReplicatedStorage.Shared.React.Common.ScrollingFrame)
local ShopDefs = require(ReplicatedStorage.Shared.Defs.ShopDefs)
local Sift = require(ReplicatedStorage.Packages.Sift)
local SystemWindow = require(ReplicatedStorage.Shared.React.Common.SystemWindow)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)
local UseCheckPrice = require(ReplicatedStorage.Shared.React.Hooks.UseCheckPrice)
local UseDeck = require(ReplicatedStorage.Shared.React.Hooks.UseDeck)
local UseMotor = require(ReplicatedStorage.Shared.React.Hooks.UseMotor)
local UseWallet = require(ReplicatedStorage.Shared.React.Hooks.UseWallet)
local UseWeapons = require(ReplicatedStorage.Shared.React.Hooks.UseWeapons)
local WeaponHelper = require(ReplicatedStorage.Shared.Util.WeaponHelper)

local function productDetails(props: {
	Product: any,
	Close: () -> (),
	Buy: () -> (),
})
	local textRatio = 1 / 15
	local reward = props.Product.Reward
	local price = props.Product.Price

	local canAfford = UseCheckPrice(price)
	local wallet = UseWallet()

	local description = RewardDisplayHelper.GetRewardDetails(reward)

	if reward.Type == "Currency" then
		description ..= `\n\nIn bag: {wallet[reward.CurrencyType]}`
	end

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
				ImageColor3 = RewardDisplayHelper.GetRewardColor(reward),
			}, {
				Preview = RewardDisplayHelper.CreateRewardElement(reward),
			}),

			Prices = React.createElement(Container, {
				LayoutOrder = 2,
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
			}, {
				Layout = React.createElement(ListLayout, {
					Padding = UDim.new(0, 4),
				}),

				Cost = React.createElement(Label, {
					Size = UDim2.fromScale(1, 0.25),
					SizeConstraint = Enum.SizeConstraint.RelativeXX,
					Text = TextStroke("Cost"),
					TextXAlignment = Enum.TextXAlignment.Left,
					LayoutOrder = -2,
				}),

				Amounts = React.createElement(
					React.Fragment,
					nil,
					Sift.Dictionary.map(
						Sift.Array.sort(Sift.Dictionary.keys(price), function(a, b)
							return a < b
						end),
						function(currencyType, currencyIndex)
							local amount = price[currencyType]
							local held = wallet[currencyType] or 0

							return React.createElement(Container, {
								LayoutOrder = currencyIndex,
								Size = UDim2.fromScale(1, 0.15),
								SizeConstraint = Enum.SizeConstraint.RelativeXX,
							}, {
								Layout = React.createElement(ListLayout, {
									FillDirection = Enum.FillDirection.Horizontal,
									Padding = UDim.new(0, 4),
								}),

								IconContainer = React.createElement(LayoutContainer, {
									Padding = 3,
									Size = UDim2.fromScale(1, 1),
									SizeConstraint = Enum.SizeConstraint.RelativeYY,
									LayoutOrder = 1,
								}, {
									IconPanel = React.createElement(Panel, {
										ImageColor3 = CurrencyDefs[currencyType].Colors.Primary,
									}, {
										Image = React.createElement(Image, {
											Image = CurrencyDefs[currencyType].Image,
										}),
									}),
								}),

								Text = React.createElement(HeightText, {
									Size = UDim2.fromScale(0, 1),
									Text = TextStroke(`{held} / {amount}`),
									AutomaticSize = Enum.AutomaticSize.X,
									TextColor3 = if held < amount then ColorDefs.PaleRed else nil,
									LayoutOrder = 2,
								}),
							}),
								currencyType
						end
					)
				),
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

			Buy = React.createElement(Button, {
				LayoutOrder = -3,
				Size = UDim2.fromScale(0.3, 1),
				[React.Event.Activated] = props.Buy,
				Active = canAfford,
				ImageColor3 = if canAfford then ColorDefs.Blue else ColorDefs.PaleRed,
			}, {
				Text = React.createElement(Label, {
					Text = TextStroke("Buy"),
				}),
			}),
		}),
	})
end

local function productSuccess(props: {
	Reward: any,
	Close: () -> (),
})
	local slide, slideMotor = UseMotor(-1.1)

	React.useEffect(function()
		slideMotor:setGoal(Flipper.Spring.new(0))

		return function()
			slideMotor:setGoal(Flipper.Instant.new(-1.1))
			slideMotor:step()
		end
	end, { props.Reward })

	return React.createElement(Container, {
		Size = UDim2.fromScale(1, 0.4),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ClipsDescendants = true,
	}, {
		Container = React.createElement(Container, {
			Position = slide:map(function(value)
				return UDim2.fromScale(value, 0)
			end),
		}, {
			Text = React.createElement(Label, {
				Size = UDim2.fromScale(1, 0.3),
				Text = TextStroke("You got:"),
			}),

			Reward = React.createElement(LayoutContainer, {
				Padding = 8,
				Size = UDim2.fromScale(1, 0.3),
				Position = UDim2.fromScale(0, 0.3),
			}, {
				Layout = React.createElement(ListLayout, {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = UDim.new(0, 8),
				}),

				PreviewPanel = React.createElement(Panel, {
					LayoutOrder = 1,
					Size = UDim2.fromScale(1, 1),
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					ImageColor3 = RewardDisplayHelper.GetRewardColor(props.Reward),
				}, {
					Preview = RewardDisplayHelper.CreateRewardElement(props.Reward),
				}),

				Text = React.createElement(HeightText, {
					Size = UDim2.fromScale(0, 1),
					AutomaticSize = Enum.AutomaticSize.X,
					LayoutOrder = 2,
					Text = TextStroke(RewardDisplayHelper.GetRewardText(props.Reward)),
				}),
			}),

			Confirm = React.createElement(LayoutContainer, {
				Padding = 8,
				Size = UDim2.fromScale(0.2, 0.4),
				Position = UDim2.fromScale(0.5, 0.6),
				AnchorPoint = Vector2.new(0.5, 0),
			}, {
				Button = React.createElement(Button, {
					ImageColor3 = ColorDefs.DarkPurple,
					[React.Event.Activated] = function()
						PromiseMotor(slideMotor, Flipper.Spring.new(1.1), function(value)
							return value > 1
						end):andThenCall(props.Close)
					end,
				}, {
					Label = React.createElement(Label, {
						Text = TextStroke("Okay"),
					}),
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
	local state, setState = React.useState("Shop")
	local selectedProduct, setSelectedProduct = React.useState(nil)
	local receivedReward, setReceivedReward = React.useState(nil)

	local shopId = `Premium{category}`
	local def = ShopDefs[shopId]

	local deck = UseDeck()
	local weapons = UseWeapons()

	return React.createElement(SystemWindow, {
		Visible = props.Visible,
		HeaderText = TextStroke(def.Name),
		[React.Event.Activated] = props.Close,
		RatioDisabled = true,
		Size = UDim2.fromScale(1.2, 0.8),
		HeaderSize = 0.075,
	}, {
		Reception = (state == "Reception") and React.createElement(productSuccess, {
			Reward = receivedReward,
			Close = function()
				if receivedReward.Type == "Card" or receivedReward.Type == "Weapon" then
					setState("Shop")
				else
					setState("Details")
				end

				setReceivedReward(nil)
			end,
		}),

		ProductDetails = (state == "Details") and React.createElement(productDetails, {
			Product = selectedProduct,
			Close = function()
				setSelectedProduct(nil)
				setState("Shop")
			end,
			Buy = function()
				setState("Waiting")

				GenericShopController.BuyProduct(shopId, selectedProduct.Index):andThen(function(success)
					if success then
						setReceivedReward(selectedProduct.Reward)
						setState("Reception")
					else
						setState("Details")
					end
				end, function()
					setState("Details")
				end)
			end,
		}),

		Products = React.createElement(Container, {
			Visible = state == "Shop",
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

			Products = React.createElement(ScrollingFrame, {
				Size = UDim2.fromScale(1, 0.85),
				Position = UDim2.fromScale(0, 0.15),
				RenderLayout = function(setCanvasSize)
					return React.createElement(ListLayout, {
						[React.Change.AbsoluteContentSize] = function(object)
							setCanvasSize(UDim2.fromOffset(0, object.AbsoluteContentSize.Y))
						end,
					})
				end,
			}, {
				Panels = React.createElement(
					React.Fragment,
					nil,
					Sift.Array.map(def.Products, function(product, index)
						local price = product.Price
						local reward = product.Reward

						if reward.Type == "Card" and DeckHelper.OwnsCard(deck, reward.CardId) then return end
						if reward.Type == "Weapon" and WeaponHelper.OwnsWeapon(weapons, reward.WeaponId) then return end

						return React.createElement(LayoutContainer, {
							Size = UDim2.fromScale(1, 0.16),
							SizeConstraint = Enum.SizeConstraint.RelativeXX,
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
										ImageColor3 = RewardDisplayHelper.GetRewardColor(reward),
									}, {
										Preview = RewardDisplayHelper.CreateRewardElement(reward),
									}),

									Right = React.createElement(Container, {
										LayoutOrder = 2,
										Size = UDim2.fromScale(0, 1),
										AutomaticSize = Enum.AutomaticSize.X,
									}, {
										Name = React.createElement(HeightText, {
											Size = UDim2.fromScale(0, 0.5),
											Text = TextStroke(RewardDisplayHelper.GetRewardText(reward, true)),
											TextXAlignment = Enum.TextXAlignment.Left,
											AutomaticSize = Enum.AutomaticSize.X,
										}),

										Price = React.createElement(Container, {
											Size = UDim2.fromScale(0, 0.5),
											Position = UDim2.fromScale(0, 0.5),
											AutomaticSize = Enum.AutomaticSize.X,
										}, {
											Layout = React.createElement(ListLayout, {
												FillDirection = Enum.FillDirection.Horizontal,
												Padding = UDim.new(0, 6),
											}),

											Prices = React.createElement(
												React.Fragment,
												nil,
												Sift.Dictionary.map(
													Sift.Array.sort(Sift.Dictionary.keys(price), function(a, b)
														return a < b
													end),
													function(currencyType, currencyIndex)
														local amount = price[currencyType]
														local order = currencyIndex * 2

														return React.createElement(React.Fragment, nil, {
															IconContainer = React.createElement(LayoutContainer, {
																Padding = 3,
																Size = UDim2.fromScale(1, 1),
																SizeConstraint = Enum.SizeConstraint.RelativeYY,
																LayoutOrder = order,
															}, {
																IconPanel = React.createElement(Panel, {
																	ImageColor3 = CurrencyDefs[currencyType].Colors.Primary,
																}, {
																	Image = React.createElement(Image, {
																		Image = CurrencyDefs[currencyType].Image,
																	}),
																}),
															}),

															Text = React.createElement(HeightText, {
																Size = UDim2.fromScale(0, 1),
																Text = TextStroke(`{amount}`),
																AutomaticSize = Enum.AutomaticSize.X,
																LayoutOrder = order + 1,
															}),
														}),
															currencyType
													end
												)
											),
										}),
									}),
								}),

								Button = React.createElement(LayoutContainer, {
									Padding = 10,
									Size = UDim2.fromScale(0.25, 1),
									AnchorPoint = Vector2.new(1, 0),
									Position = UDim2.fromScale(1, 0),
								}, {
									Button = React.createElement(Button, {
										ImageColor3 = ColorDefs.DarkRed,
										BorderSizePixel = 2,
										[React.Event.Activated] = function()
											setSelectedProduct(product)
											setState("Details")
										end,
									}, {
										Label = React.createElement(Label, {
											Text = "Select",
										}),
									}),
								}),
							}),
						}),
							def.Id
					end)
				),
			}),
		}),
	})
end
