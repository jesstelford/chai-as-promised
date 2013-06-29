"use strict"

describe "Promise-specific extensions:", ->
    promise = null
    error = new Error("boo")

    assertingDoneFactory = (done) ->
        (result) ->
            try
                expect(result).to.equal(error)
            catch assertionError
                return done(assertionError)

            done()

    describe.only "when the promise is fulfilled", ->
        beforeEach ->
            promise = fulfilledPromise()

        describe ".fulfilled", ->
            shouldPass -> promise.should.be.fulfilled
        describe.only ".not.fulfilled", ->
            shouldFail
                op: -> promise.should.not.be.fulfilled
                message: "not to be fulfilled but it was fulfilled with undefined"

        describe ".rejected", ->
            shouldFail
              op: -> promise.should.be.rejected
              message: "to be rejected but it was fulfilled with undefined"
        describe ".rejectedWith(TypeError)", ->
            shouldFail
                op: -> promise.should.be.rejectedWith(TypeError)
                message: "to be rejected with 'TypeError' but it was fulfilled with undefined"
        describe ".rejectedWith('message substring')", ->
            shouldFail
                op: -> promise.should.be.rejectedWith("message substring")
                message: "to be rejected with an error including 'message substring' but it was fulfilled with " +
                         "undefined"
        describe ".rejectedWith(/regexp/)", ->
            shouldFail
                op: -> promise.should.be.rejectedWith(/regexp/)
                message: "to be rejected with an error matching /regexp/ but it was fulfilled with undefined"
        describe ".rejectedWith(TypeError, 'message substring')", ->
            shouldFail
                op: -> promise.should.be.rejectedWith(TypeError, "message substring")
                message: "to be rejected with 'TypeError' but it was fulfilled with undefined"
        describe ".rejectedWith(TypeError, /regexp/)", ->
            shouldFail
                op: -> promise.should.be.rejectedWith(TypeError, /regexp/)
                message: "to be rejected with 'TypeError' but it was fulfilled with undefined"
        describe ".rejectedWith(errorInstance)", ->
            shouldFail
                op: -> promise.should.be.rejectedWith(error)
                message: "to be rejected with [Error: boo] but it was fulfilled with undefined"

        ###
        describe ".not.rejected", ->
            shouldPass -> promise.should.not.be.rejected
        describe ".not.rejectedWith(TypeError)", ->
            shouldPass -> promise.should.not.be.rejectedWith(TypeError)
        describe ".not.rejectedWith('message substring')", ->
            shouldPass -> promise.should.not.be.rejectedWith("message substring")
        describe ".not.rejectedWith(/regexp/)", ->
            shouldPass -> promise.should.not.be.rejectedWith(/regexp/)
        describe ".not.rejectedWith(TypeError, 'message substring')", ->
            shouldPass -> promise.should.not.be.rejectedWith(TypeError, "message substring")
        describe ".not.rejectedWith(TypeError, /regexp/)", ->
            shouldPass -> promise.should.not.be.rejectedWith(TypeError, /regexp/)
        describe ".not.rejectedWith(errorInstance)", ->
            shouldPass -> promise.should.not.be.rejectedWith(error)
        ###
        describe ".should.notify(done)", ->
            it "should pass the test", (done) ->
                promise.should.notify(done)

    describe "when the promise is rejected", ->
        beforeEach ->
            promise = rejectedPromise(error)

        describe ".fulfilled", ->
            shouldFail -> promise.should.be.fulfilled
        describe ".not.fulfilled", ->
            shouldPass -> promise.should.not.be.fulfilled

        describe ".rejected", ->
            shouldPass -> promise.should.be.rejected

        describe ".rejectedWith(theError)", ->
            shouldPass -> promise.should.be.rejectedWith(error)
        describe ".not.rejectedWith(theError)", ->
            shouldFail -> promise.should.not.be.rejectedWith(error)

        describe ".rejectedWith(differentError)", ->
            shouldFail -> promise.should.be.rejectedWith(new Error)
        describe ".not.rejectedWith(differentError)", ->
            shouldPass -> promise.should.not.be.rejectedWith(new Error)

        describe "with an Error having message 'foo bar'", ->
            beforeEach ->
                promise = rejectedPromise(new Error("foo bar"))

            describe ".rejectedWith('foo')", ->
                shouldPass -> promise.should.be.rejectedWith("foo")
            describe ".rejectedWith(/bar/)", ->
                shouldPass -> promise.should.be.rejectedWith(/bar/)

            describe ".rejectedWith('quux')", ->
                shouldFail -> promise.should.be.rejectedWith("quux")
            describe ".rejectedWith(/quux/)", ->
                shouldFail -> promise.should.be.rejectedWith(/quux/)


            describe ".not.rejectedWith('foo')", ->
                shouldFail -> promise.should.not.be.rejectedWith("foo")
            describe ".not.rejectedWith(/bar/)", ->
                shouldFail -> promise.should.not.be.rejectedWith(/bar/)

            describe ".not.rejectedWith('quux')", ->
                shouldPass -> promise.should.not.be.rejectedWith("quux")
            describe ".not.rejectedWith(/quux/)", ->
                shouldPass -> promise.should.not.be.rejectedWith(/quux/)

        describe "with a RangeError", ->
            beforeEach ->
                promise = rejectedPromise(new RangeError)

            describe ".rejectedWith(RangeError)", ->
                shouldPass -> promise.should.be.rejectedWith(RangeError)
            describe ".rejectedWith(TypeError)", ->
                shouldFail -> promise.should.be.rejectedWith(TypeError)

            describe ".not.rejectedWith(RangeError)", ->
                shouldFail -> promise.should.not.be.rejectedWith(RangeError)
            describe ".not.rejectedWith(TypeError)", ->
                shouldPass -> promise.should.not.be.rejectedWith(TypeError)

        describe "with a RangeError having a message 'foo bar'", ->
            beforeEach ->
                promise = rejectedPromise(new RangeError("foo bar"))

            describe ".rejectedWith(RangeError, 'foo')", ->
                shouldPass -> promise.should.be.rejectedWith(RangeError, "foo")
            describe ".rejectedWith(RangeError, /bar/)", ->
                shouldPass -> promise.should.be.rejectedWith(RangeError, /bar/)

            describe ".rejectedWith(RangeError, 'quux')", ->
                shouldFail -> promise.should.be.rejectedWith(RangeError, "quux")
            describe ".rejectedWith(RangeError, /quux/)", ->
                shouldFail -> promise.should.be.rejectedWith(RangeError, /quux/)

            describe ".rejectedWith(TypeError, 'foo')", ->
                shouldFail -> promise.should.be.rejectedWith(TypeError, "foo")
            describe ".rejectedWith(TypeError, /bar/)", ->
                shouldFail -> promise.should.be.rejectedWith(TypeError, /bar/)

            describe ".rejectedWith(TypeError, 'quux')", ->
                shouldFail -> promise.should.be.rejectedWith(TypeError, "quux")
            describe ".rejectedWith(TypeError, /quux/)", ->
                shouldFail -> promise.should.be.rejectedWith(TypeError, /quux/)


            describe ".not.rejectedWith(RangeError, 'foo')", ->
                shouldFail -> promise.should.not.be.rejectedWith(RangeError, "foo")
            describe ".not.rejectedWith(RangeError, /bar/)", ->
                shouldFail -> promise.should.not.be.rejectedWith(RangeError, /bar/)

            describe ".not.rejectedWith(RangeError, 'quux')", ->
                shouldFail -> promise.should.not.be.rejectedWith(RangeError, "quux")
            describe ".not.rejectedWith(RangeError, /quux/)", ->
                shouldFail -> promise.should.not.be.rejectedWith(RangeError, /quux/)

            describe ".not.rejectedWith(TypeError, 'foo')", ->
                shouldFail -> promise.should.not.be.rejectedWith(TypeError, "foo")
            describe ".not.rejectedWith(TypeError, /bar/)", ->
                shouldFail -> promise.should.not.be.rejectedWith(TypeError, /bar/)

            describe ".not.rejectedWith(TypeError, 'quux')", ->
                shouldPass -> promise.should.not.be.rejectedWith(TypeError, "quux")
            describe ".not.rejectedWith(TypeError, /quux/)", ->
                shouldPass -> promise.should.not.be.rejectedWith(TypeError, /quux/)

        describe ".should.notify(done)", ->
            it "should fail the test with the original error", (done) ->
                promise.should.notify(assertingDoneFactory(done))

    ###
    describe ".should.notify with chaining (GH-3)", ->
        describe "the original promise is fulfilled", ->
            beforeEach -> promise = fulfilledPromise()

            describe "and the follow-up promise is fulfilled", ->
                beforeEach -> promise = promise.then(->)

                it "should pass the test", (done) ->
                    promise.should.notify(done)

            describe "but the follow-up promise is rejected", ->
                beforeEach -> promise = promise.then(-> throw error)

                it "should fail the test with the error from the follow-up promise", (done) ->
                    promise.should.notify(assertingDoneFactory(done))

        describe "the original promise is rejected", ->
            beforeEach -> promise = rejectedPromise(error)

            describe "but the follow-up promise is fulfilled", ->
                beforeEach -> promise = promise.then(->)

                it "should fail the test with the error from the original promise", (done) ->
                    promise.should.notify(assertingDoneFactory(done))

            describe "and the follow-up promise is rejected", ->
                beforeEach -> promise = promise.then(-> throw new Error("follow up"))

                it "should fail the test with the error from the original promise", (done) ->
                    promise.should.notify(assertingDoneFactory(done))

    describe "Using with non-promises:", ->
        describe "A number", ->
            number = 5

            it "should fail for .fulfilled", ->
                expect(-> number.should.be.fulfilled).to.throw(TypeError, /not a promise/)
            it "should fail for .rejected", ->
                expect(-> number.should.be.rejected).to.throw(TypeError, /not a promise/)
            it "should fail for .become", ->
                expect(-> number.should.become(5)).to.throw(TypeError, /not a promise/)
            it "should fail for .eventually", ->
                expect(-> number.should.eventually.equal(5)).to.throw(TypeError, /not a promise/)
            it "should fail for .notify", ->
                expect(-> number.should.notify(->)).to.throw(TypeError, /not a promise/)

    describe "Attempts to use multiple Chai as Promised properties in an assertion", ->
        shouldTellUsNo = (func) ->
            it "should fail with an informative error message", ->
                expect(func).to.throw(Error, /Chai as Promised/)

        describe ".fulfilled.and.eventually.equal(42)", ->
            shouldTellUsNo -> fulfilledPromise(42).should.be.fulfilled.and.eventually.equal(42)
        describe ".fulfilled.and.become(42)", ->
            shouldTellUsNo -> fulfilledPromise(42).should.be.fulfilled.and.become(42)
        describe ".fulfilled.and.rejected", ->
            shouldTellUsNo -> fulfilledPromise(42).should.be.fulfilled.and.rejected

        describe ".rejected.and.eventually.equal(42)", ->
            shouldTellUsNo -> rejectedPromise(42).should.be.rejected.and.eventually.equal(42)
        describe ".rejected.and.become(42)", ->
            shouldTellUsNo -> rejectedPromise(42).should.be.rejected.and.become(42)
        describe ".rejected.and.fulfilled", ->
            shouldTellUsNo -> rejectedPromise(42).should.be.rejected.and.fulfilled
    ###
