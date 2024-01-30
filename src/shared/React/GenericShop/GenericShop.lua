local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Aspect = require(ReplicatedStorage.Shared.React.Common.Aspect)
local Button = require(ReplicatedStorage.Shared.React.Common.Button)
local ColorDefs = require(ReplicatedStorage.Shared.Defs.ColorDefs)
local Container = require(ReplicatedStorage.Shared.React.Common.Container)
local CurrencyDefs = require(ReplicatedStorage.Shared.Defs.CurrencyDefs)
local FormatBigNumber = require(ReplicatedStorage.Shared.Util.FormatBigNumber)
local HeightText = require(ReplicatedStorage.Shared.React.Common.HeightText)
local Image = require(ReplicatedStorage.Shared.React.Common.Image)
local Label = require(ReplicatedStorage.Shared.React.Common.Label)
local LayoutContainer = require(ReplicatedStorage.Shared.React.Common.LayoutContainer)
local ListLayout = require(ReplicatedStorage.Shared.React.Common.ListLayout)
local PaddingAll = require(ReplicatedStorage.Shared.React.Common.PaddingAll)
local Panel = require(ReplicatedStorage.Shared.React.Common.Panel)
local RatioText = require(ReplicatedStorage.Shared.React.Common.RatioText)
local React = require(ReplicatedStorage.Packages.React)
local RewardDisplayHelper = require(ReplicatedStorage.Shared.Util.RewardDisplayHelper)
local ScrollingFrame = require(ReplicatedStorage.Shared.React.Common.ScrollingFrame)
local ShopDefs = require(ReplicatedStorage.Shared.Defs.ShopDefs)
local Sift = require(ReplicatedStorage.Packages.Sift)
local SystemWindow = require(ReplicatedStorage.Shared.React.Common.SystemWindow)
local TextStroke = require(ReplicatedStorage.Shared.React.Util.TextStroke)

local function productDetails(props: {
	Product: any,
	Close: () -> (),
	Buy: () -> (),
})
	local textRatio = 1 / 15
	local reward = props.Product.Reward
	local price = props.Product.Price

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

							return React.createElement(Container, {
								LayoutOrder = currencyIndex,
								Size = UDim2.fromScale(1, 0.2),
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
									Text = TextStroke(`{amount}`),
									AutomaticSize = Enum.AutomaticSize.X,
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
					Text = TextStroke(RewardDisplayHelper.GetRewardDetails(reward)),
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
				Active = true, -- disable if can't afford
				ImageColor3 = ColorDefs.Blue,
			}, {
				Text = React.createElement(Label, {
					Text = TextStroke("Buy"),
				}),
			}),
		}),
	})
end

return function(props: {
	Visible: boolean,
	ShopId: string,
	Buy: (string) -> (),
	Close: () -> (),
})
	local def = ShopDefs[props.ShopId]
	local selectedProduct, setSelectedProduct = React.useState(nil)

	return React.createElement(SystemWindow, {
		Visible = props.Visible,
		HeaderText = TextStroke(def.Name),
		[React.Event.Activated] = props.Close,
		RatioDisabled = true,
		Size = UDim2.fromScale(1.2, 0.8),
		HeaderSize = 0.075,
	}, {
		ProductDetails = (selectedProduct ~= nil) and React.createElement(productDetails, {
			Product = selectedProduct,
			Close = function()
				setSelectedProduct(nil)
			end,
			Buy = function()
				print(`Buy product {selectedProduct.Index}`)
				setSelectedProduct(nil)
			end,
		}),

		Products = (selectedProduct == nil) and React.createElement(ScrollingFrame, {
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

					return React.createElement(LayoutContainer, {
						Size = UDim2.fromScale(1, 0.15),
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
	})
end
