<?php

namespace rockunit;

use rock\behaviors\TimestampBehavior;
use rock\db\Expression;
use rock\db\Query;
use rockunit\models\ActiveRecord;
use rockunit\models\Order;
use rockunit\models\OrderTimestamp;

/**
 * @group behaviors
 * @group db
 */
class TimestampBehaviorTest extends DatabaseTestCase
{
    protected function setUp()
    {
        parent::setUp();
        ActiveRecord::$connection = $this->getConnection();

        $columns = [
            'id' => 'pk',
            'created_at' => 'integer NOT NULL',
            'updated_at' => 'integer',
        ];
        (new Query())->createCommand(ActiveRecord::$connection)->createTable('test_auto_timestamp', $columns, null, true)->execute();
        $columns = [
            'id' => 'pk',
            'created_at' => 'string NOT NULL',
            'updated_at' => 'string',
        ];
        (new Query())->createCommand(ActiveRecord::$connection)->createTable('test_auto_timestamp_string', $columns, null, true)->execute();
    }

    public function testInsert()
    {
        $query= new Order();
        $query->customer_id = 2;
        $query->total = 77;
        $this->assertNull($query->created_at);
        $this->assertTrue($query->save());
        $this->assertNotEmpty($query->created_at);
        $this->assertSame($query->created_at, $query::findOne($query->getPrimaryKey())->created_at);
        //$this->assertTrue((bool)Articles::deleteAll(['id' => $query->getPrimaryKey()]));

        $query= new OrderTimestamp();
        $query->customer_id = 2;
        $query->total = 77;
        $this->assertNull($query->created_at);
        $this->assertTrue($query->save());
        $this->assertNotEmpty($query->created_at);
        $this->assertSame($query->created_at, $query::findOne($query->getPrimaryKey())->created_at);
    }

    public function testUpdate()
    {
        $query = Order::findOne(2);
        $created_at = $query->created_at;
        $query->total = 55;
        $this->assertTrue($query->save());
        $this->assertNotEmpty($query->created_at);
        $this->assertNotEquals($created_at, $query->created_at);
        $this->assertSame($query->created_at, $query::findOne($query->getPrimaryKey())->created_at);
    }

    public function testNewRecord()
    {
        $currentTime = time();
        ActiveRecordTimestamp::$behaviors = [
            [
                'class' => TimestampBehavior::className(),
                'createdAtAttribute' => 'created_at',
                'updatedAtAttribute' => 'updated_at'
            ]
        ];
        $model = new ActiveRecordTimestamp();
        $model->save(false);
        $this->assertTrue($model->created_at >= $currentTime);
        $this->assertTrue($model->updated_at >= $currentTime);
    }
    /**
     * @depends testNewRecord
     */
    public function testUpdateRecord()
    {
        $currentTime = time();
        ActiveRecordTimestamp::$behaviors = [
            [
                'class' => TimestampBehavior::className(),
                'createdAtAttribute' => 'created_at',
                'updatedAtAttribute' => 'updated_at'
            ]
        ];
        $model = new ActiveRecordTimestamp();
        $model->save(false);
        $enforcedTime = $currentTime - 100;
        $model->created_at = $enforcedTime;
        $model->updated_at = $enforcedTime;
        $model->save(false);
        $this->assertEquals($enforcedTime, $model->created_at, 'Create time has been set on update!');
        $this->assertTrue($model->updated_at >= $currentTime, 'Update time has NOT been set on update!');
    }

    public function expressionProvider()
    {
        return [
            [function() { return '2015-01-01'; }, '2015-01-01'],
            [new Expression("YEAR(NOW())"), date('Y')],
        ];
    }

    /**
     * @dataProvider expressionProvider
     */
    public function testNewRecordExpression($expression, $expected)
    {

            ActiveRecordTimestamp::$tableName = 'test_auto_timestamp_string';
            ActiveRecordTimestamp::$behaviors = [
                    'timestamp' => [
                            'class' => TimestampBehavior::className(),
                            'value' => $expression,
                            'createdAtAttribute' => 'created_at',
                            'updatedAtAttribute' => 'updated_at'
                        ],
                ];
            $model = new ActiveRecordTimestamp();
            $model->save(false);
            if ($expression instanceof Expression) {
                    $this->assertInstanceOf(Expression::className(), $model->created_at);
                    $this->assertInstanceOf(Expression::className(), $model->updated_at);
                    $model->refresh();
                }
        $this->assertEquals($expected, $model->created_at);
        $this->assertEquals($expected, $model->updated_at);
    }

    /**
     * @depends testNewRecord
     */
    public function testUpdateRecordExpression()
    {
        ActiveRecordTimestamp::$tableName = 'test_auto_timestamp_string';
        ActiveRecordTimestamp::$behaviors = [
            'timestamp' => [
                'class' => TimestampBehavior::className(),
                'value' => new Expression("YEAR(NOW())"),
                'createdAtAttribute' => 'created_at',
                'updatedAtAttribute' => 'updated_at'
            ],
        ];
        $model = new ActiveRecordTimestamp();
        $model->save(false);
        $enforcedTime = date('Y') - 1;
        $model->created_at = $enforcedTime;
        $model->updated_at = $enforcedTime;
        $model->save(false);
        $this->assertEquals($enforcedTime, $model->created_at, 'Create time has been set on update!');
        $this->assertInstanceOf(Expression::className(), $model->updated_at);
        $model->refresh();
        $this->assertEquals($enforcedTime, $model->created_at, 'Create time has been set on update!');
        $this->assertEquals(date('Y'), $model->updated_at);
    }
}


/**
 * Test Active Record class with TimestampBehavior behavior attached.
 *
 * @property integer $id
 * @property integer $created_at
 * @property integer $updated_at
 */
class ActiveRecordTimestamp extends ActiveRecord
{
    public static $behaviors;
    public static $tableName = 'test_auto_timestamp';
    public function behaviors()
    {
        return static::$behaviors;
    }
    public static function tableName()
    {
        return static::$tableName;
    }
}