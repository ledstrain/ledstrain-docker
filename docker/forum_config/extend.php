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

class JsonDataCache
{
    private static $cache = null;
    private static $filePath = null;

    /**
     * Get cached JSON data or read from file if not cached
     *
     * @param string $jsonFilePath Path to the JSON file
     * @return array The decoded JSON data
     * @throws RuntimeException If file cannot be read or JSON is invalid
     */
    public static function getCachedData($jsonFilePath)
    {
        // If cache is empty or file path changed, read from file
        if (self::$cache === null || self::$filePath !== $jsonFilePath) {
            self::$cache = self::loadJsonFromFile($jsonFilePath);
            self::$filePath = $jsonFilePath;
        }

        return self::$cache;
    }

    /**
     * Load and decode JSON data from file
     *
     * @param string $filePath Path to the JSON file
     * @return array The decoded JSON data
     * @throws RuntimeException If file cannot be read or JSON is invalid
     */
    private static function loadJsonFromFile($filePath)
    {
        if (!file_exists($filePath)) {
            throw new RuntimeException("JSON file not found: {$filePath}");
        }

        if (!is_readable($filePath)) {
            throw new RuntimeException("JSON file is not readable: {$filePath}");
        }

        $jsonContent = file_get_contents($filePath);

        if ($jsonContent === false) {
            throw new RuntimeException("Failed to read JSON file: {$filePath}");
        }

        $decodedData = json_decode($jsonContent, true);

        if (json_last_error() !== JSON_ERROR_NONE) {
            throw new RuntimeException("Invalid JSON in file {$filePath}: " . json_last_error_msg());
        }

        if (!is_array($decodedData)) {
            throw new RuntimeException("JSON file must contain an array: {$filePath}");
        }

        return $decodedData;
    }
}

$newUserAllowedDomains = JsonDataCache::getCachedData(__DIR__.'/new_user_allowed_domains.json');

return [
    (new Spam\Filter)
        // use domain name
        // ->allowLinksFromDomain('luceos.com')
        // or just a full domain with protocol, only the host name is used
        // ->allowLinksFromDomain('http://flarum.org')
        // even a link works, only the domain will be used
        // ->allowLinksFromDomain('discuss.flarum.org/d/26095')
        // Alternatively, use an array of domains
      ->allowLinksFromDomains($newUserAllowedDomains)
        // Use custom (expert) logic.
        // Return true to ignore further checking this link for validity.
        // ->allowLink(function (Uri $uri, User $actor = null) {
        //     if ($uri->getHost() === '127.0.0.1') return true;
        // })
        // How long after sign up all posts are scrutinized for bad content
        ->checkForUserUpToHoursSinceSignUp(48)
        // How many of the first posts of a user to scrutinize for bad content
        ->checkForUserUpToPostContribution(4)
        // Specify the user Id of the moderator raising flags for some actions, otherwise the first admin is used
        // ->moderateAsUser(2)
        // Disable specific spam prevention components
        // ->disable(\Blomstra\Spam\Filters\UserBio::class),
];
