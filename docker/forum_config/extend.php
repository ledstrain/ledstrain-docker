<?php

/*
 * This file is part of Flarum.
 *
 * For detailed copyright and license information, please view the
 * LICENSE file that was distributed with this source code.
 */


use Flarum\Extend;
use Blomstra\Spam;
use Laminas\Diactoros\Uri;
use Flarum\User\User;

return [
    (new Spam\Filter)
        // use domain name
        // ->allowLinksFromDomain('luceos.com')
        // or just a full domain with protocol, only the host name is used
        // ->allowLinksFromDomain('http://flarum.org')
        // even a link works, only the domain will be used
        // ->allowLinksFromDomain('discuss.flarum.org/d/26095')
        // Alternatively, use an array of domains
      ->allowLinksFromDomains(json_decode(file_get_contents(__DIR__.'/new_user_allowed_domains.json')))
        // Use custom (expert) logic.
        // Return true to ignore further checking this link for validity.
        // ->allowLink(function (Uri $uri, User $actor = null) {
        //     if ($uri->getHost() === '127.0.0.1') return true;
        // })
        // How long after sign up all posts are scrutinized for bad content
        // ->checkForUserUpToHoursSinceSignUp(48)
        // How many of the first posts of a user to scrutinize for bad content
        ->checkForUserUpToPostContribution(4)
        // Specify the user Id of the moderator raising flags for some actions, otherwise the first admin is used
        // ->moderateAsUser(2)
        // Disable specific spam prevention components
        // ->disable(\Blomstra\Spam\Filters\UserBio::class),
];
