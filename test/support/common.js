"use strict";

global.shouldPass = function (promiseProducer) {
    it("should return a fulfilled promise", function (done) {
        promiseProducer().then(done, function (reason) {
            done(new Error('Expected promise to be fulfilled but it was rejected with ' + reason));
        });
    });
};

global.shouldFail = function (promiseProducer) {
    it("should return a promise rejected with an assertion error", function (done) {
        promiseProducer().then(function () {
            done(new Error('Expected promise to be rejected with an assertion error, but it was fulfilled'));
        }, function (reason) {
            if (reason.constructor.name !== 'AssertionError') {
                done(new Error('Expected promise to be rejected with an AssertionError but it was rejected with ' +
                               reason));
            } else {
                done();
            }
        });
    });
};
