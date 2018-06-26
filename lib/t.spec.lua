return function()
	local t = require(script.Parent.t)

	it("should understand basic types", function()
		expect(t.any("")).to.equal(true)
		expect(t.boolean(true)).to.equal(true)
		expect(t.none(nil)).to.equal(true)
		expect(t.number(1)).to.equal(true)
		expect(t.string("foo")).to.equal(true)
		expect(t.table({})).to.equal(true)

		expect(t.any(nil)).to.equal(false)
		expect(t.boolean("true")).to.equal(false)
		expect(t.none(1)).to.equal(false)
		expect(t.number(true)).to.equal(false)
		expect(t.string(true)).to.equal(false)
		expect(t.table(82)).to.equal(false)
	end)

	it("should understand special number types", function()
		local maxTen = t.numberMax(10)
		local minTwo = t.numberMin(2)
		local maxTenEx = t.numberMaxExclusive(10)
		local minTwoEx = t.numberMinExclusive(2)
		local constrainedEightToEleven = t.numberConstrained(8, 11)
		local constrainedEightToElevenEx = t.numberConstrainedExclusive(8, 11)

		expect(maxTen(5)).to.equal(true)
		expect(maxTen(10)).to.equal(true)
		expect(maxTen(11)).to.equal(false)
		expect(maxTen()).to.equal(false)

		expect(minTwo(5)).to.equal(true)
		expect(minTwo(2)).to.equal(true)
		expect(minTwo(1)).to.equal(false)
		expect(minTwo()).to.equal(false)

		expect(maxTenEx(5)).to.equal(true)
		expect(maxTenEx(9)).to.equal(true)
		expect(maxTenEx(10)).to.equal(false)
		expect(maxTenEx()).to.equal(false)

		expect(minTwoEx(5)).to.equal(true)
		expect(minTwoEx(3)).to.equal(true)
		expect(minTwoEx(2)).to.equal(false)
		expect(minTwoEx()).to.equal(false)

		expect(constrainedEightToEleven(7)).to.equal(false)
		expect(constrainedEightToEleven(8)).to.equal(true)
		expect(constrainedEightToEleven(9)).to.equal(true)
		expect(constrainedEightToEleven(11)).to.equal(true)
		expect(constrainedEightToEleven(12)).to.equal(false)
		expect(constrainedEightToEleven()).to.equal(false)

		expect(constrainedEightToElevenEx(7)).to.equal(false)
		expect(constrainedEightToElevenEx(8)).to.equal(false)
		expect(constrainedEightToElevenEx(9)).to.equal(true)
		expect(constrainedEightToElevenEx(11)).to.equal(false)
		expect(constrainedEightToElevenEx(12)).to.equal(false)
		expect(constrainedEightToElevenEx()).to.equal(false)
	end)

	it("should understand optional", function()
		local check = t.optional(t.string)
		expect(check("")).to.equal(true)
		expect(check()).to.equal(true)
		expect(check(1)).to.equal(false)
	end)

	it("should understand tuples", function()
		local myTupleCheck = t.tuple(t.number, t.string, t.optional(t.number))
		expect(myTupleCheck(1, "2", 3)).to.equal(true)
		expect(myTupleCheck(1, "2")).to.equal(true)
		expect(myTupleCheck(1, "2", "3")).to.equal(false)
	end)

	it("should understand unions", function()
		local numberOrString = t.union(t.number, t.string)
		expect(numberOrString(1)).to.equal(true)
		expect(numberOrString("1")).to.equal(true)
		expect(numberOrString(nil)).to.equal(false)
	end)

	it("should understand intersections", function()
		local integerMax5000 = t.intersection(t.integer, t.numberMax(5000))
		expect(integerMax5000(1)).to.equal(true)
		expect(integerMax5000(5001)).to.equal(false)
		expect(integerMax5000(1.1)).to.equal(false)
		expect(integerMax5000("1")).to.equal(false)
	end)

	it("should understand arrays", function()
		local stringArray = t.strictArray(t.string)
		local stringValues = t.strictValues(t.string)
		expect(t.array("foo")).to.equal(false)
		expect(t.array({1, "2", 3})).to.equal(true)
		expect(stringArray({1, "2", 3})).to.equal(false)
		expect(stringArray()).to.equal(false)
		expect(stringValues()).to.equal(false)
		expect(t.array({"1", "2", "3"}, t.string)).to.equal(true)
		expect(t.array({
			foo = "bar"
		})).to.equal(false)
		expect(t.array({
			[1] = "non",
			[5] = "sequential"
		})).to.equal(false)
	end)

	it("should understand maps", function()
		local stringNumberMap = t.map(t.string, t.number)
		expect(stringNumberMap({})).to.equal(true)
		expect(stringNumberMap({a = 1})).to.equal(true)
		expect(stringNumberMap({[1] = "a"})).to.equal(false)
		expect(stringNumberMap({a = "a"})).to.equal(false)
		expect(stringNumberMap()).to.equal(false)
	end)

	it("should understand interfaces", function()
		local IVector3 = t.interface({
			x = t.number,
			y = t.number,
			z = t.number,
		})

		expect(IVector3({
			w = 0,
			x = 1,
			y = 2,
			z = 3,
		})).to.equal(true)

		expect(IVector3({
			w = 0,
			x = 1,
			y = 2,
		})).to.equal(false)
	end)

	it("should understand deep interfaces", function()
		local IPlayer = t.interface({
			name = t.string,
			inventory = t.interface({
				size = t.number
			})
		})

		expect(IPlayer({
			name = "TestPlayer",
			inventory = {
				size = 1
			}
		})).to.equal(true)

		expect(IPlayer({
			inventory = {
				size = 1
			}
		})).to.equal(false)

		expect(IPlayer({
			name = "TestPlayer",
			inventory = {
			}
		})).to.equal(false)

		expect(IPlayer({
			name = "TestPlayer",
		})).to.equal(false)
	end)

	it("should understand deep optional interfaces", function()
		local IPlayer = t.interface({
			name = t.string,
			inventory = t.optional(t.interface({
				size = t.number
			}))
		})

		expect(IPlayer({
			name = "TestPlayer"
		})).to.equal(true)

		expect(IPlayer({
			name = "TestPlayer",
			inventory = {
			}
		})).to.equal(false)

		expect(IPlayer({
			name = "TestPlayer",
			inventory = {
				size = 1
			}
		})).to.equal(true)
	end)

	it("should understand Roblox Instances", function()
		local stringValueCheck = t.instanceOf("StringValue")
		local stringValue = Instance.new("StringValue")
		local boolValue = Instance.new("BoolValue")

		expect(stringValueCheck(stringValue)).to.equal(true)
		expect(stringValueCheck(boolValue)).to.equal(false)
		expect(stringValueCheck()).to.equal(false)
	end)

	it("should understand Roblox Instance Inheritance", function()
		local guiObjectCheck = t.instanceIsA("GuiObject")
		local frame = Instance.new("Frame")
		local textLabel = Instance.new("TextLabel")
		local stringValue = Instance.new("StringValue")

		expect(guiObjectCheck(frame)).to.equal(true)
		expect(guiObjectCheck(textLabel)).to.equal(true)
		expect(guiObjectCheck(stringValue)).to.equal(false)
		expect(guiObjectCheck()).to.equal(false)
	end)
end