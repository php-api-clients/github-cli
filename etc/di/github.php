<?php declare(strict_types=1);

use ApiClients\Client\Github\AsyncClient;
use ApiClients\Client\Github\AsyncClientInterface;
use ApiClients\Client\Github\Authentication\Anonymous;
use ApiClients\Client\Github\Authentication\Token;
use React\EventLoop\LoopInterface;

return [
    AsyncClientInterface::class => function (
        LoopInterface $loop
    ) {
        $client = AsyncClient::create(
            $loop,
            strlen(getenv('GITHUB_TOKEN')) > 0 ? new Token(getenv('GITHUB_TOKEN')) : new Anonymous()
        );

        return $client;
    },
];