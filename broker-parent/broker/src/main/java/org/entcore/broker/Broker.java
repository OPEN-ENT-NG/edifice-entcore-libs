package org.entcore.broker;

import io.vertx.core.Future;
import io.vertx.core.Promise;
import io.vertx.core.logging.Logger;
import io.vertx.core.logging.LoggerFactory;
import org.entcore.broker.client.BrokerClient;
import org.entcore.broker.client.BrokerClientFactory;
import org.vertx.java.busmods.BusModBase;

public class Broker extends BusModBase {

  private static final Logger log = LoggerFactory.getLogger(Broker.class);

  private BrokerClient brokerClient;

  public void start(final Promise<Void> startPromise) throws Exception {
    final Promise<Void> promise = Promise.promise();
    super.start(promise);
    promise.future()
            .compose(init -> initBroker())
            .onComplete(startPromise);
  }

  public Future<Void> initBroker() {
      final Promise<Void> promise = Promise.promise();
      brokerClient = BrokerClientFactory.getClient(vertx);
      brokerClient.start().onComplete(ar -> {
        if (ar.succeeded()) {
          log.info("Broker client started successfully.");
          promise.tryComplete();
        } else {
          log.error("Failed to start broker client.", ar.cause());
          promise.tryFail(ar.cause());
        }
      });
      return promise.future();
  }

  @Override
  public void stop(Promise<Void> stopPromise) throws Exception {
    log.info("Stopping Broker...");
    super.stop(stopPromise);
    brokerClient.close().onSuccess(e -> {
      log.info("Broker client stopped successfully.");
      stopPromise.tryComplete();
    }).onFailure(err -> {
      log.error("Failed to stop broker client.", err);
      stopPromise.tryFail(err);
    });
  }
}
