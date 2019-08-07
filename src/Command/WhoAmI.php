<?php declare(strict_types=1);

namespace ApiClients\Cli\Github\Command;

use ApiClients\Client\Github\AsyncClientInterface;
use ApiClients\Tools\Psr7\HttpStatusExceptions\UnauthorizedException;
use ReactiveApps\Command\Command;

class WhoAmI implements Command
{
    const COMMAND = 'who-am-i';

    /** @var AsyncClientInterface */
    private $github;

    public function __construct(AsyncClientInterface $github)
    {
        $this->github = $github;
    }

    public function __invoke()
    {
        try {
            echo 'You are: ', (yield $this->github->whoami())->name(), PHP_EOL;
        } catch (UnauthorizedException $unauthorizedException) {
            echo 'You are anonymous', PHP_EOL;
        } catch (\Throwable $throwable) {
            echo $throwable;
        }

        die();
    }
}
