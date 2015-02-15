<?php

namespace rockunit\common;


use League\Flysystem\Adapter\Local;
use rock\cache\CacheFile;
use rock\file\FileManager;
use rock\helpers\FileHelper;

trait CommonTestTrait
{
    protected static function clearRuntime()
    {
        $runtime = ROCKUNIT_RUNTIME;
        FileHelper::deleteDirectory($runtime);
    }

    protected static function sort($value)
    {
        ksort($value);
        return $value;
    }
} 