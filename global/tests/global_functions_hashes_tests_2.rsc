:global RunAllHashesTests2
:global GetSha512SumTest

:set RunAllHashesTests2 do={
    :global GetSha512SumTest

    :local res [$InitTestCaseState $1]

    :put "\1B[35m=== STARTING ALL HASHES TESTS 2 ===\1B[0m"

    :set res [$GetSha512SumTest $res]

    :put "\1B[35m=== ALL HASHES TESTS 2 COMPLETED ===\1B[0m"

    :return $res
}

:set GetSha512SumTest do={
    :global InitTestCaseState
    :global GetSha512Sum
    :global DecToChar
    :global RunTestCase

    :local res [$InitTestCaseState $1]

    :put "Starting GetSha512Sum tests..."

    :set res [$RunTestCase $res $GetSha512Sum "" "nothing" "nothing" \
        "cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e" \
        "Empty string boundary hash"]

    :set res [$RunTestCase $res $GetSha512Sum "a" "nothing" "nothing" \
        "1f40fc92da241694750979ee6cf582f2d5d7d28e18335de05abc54d0560e0f5302860c652bf08d560252aa5e74210546f369fbbbce8c12cfc7957b2652fe9a75" \
        "Single lowercase character string hash"]

    :set res [$RunTestCase $res $GetSha512Sum "abc" "nothing" "nothing" \
        "ddaf35a193617abacc417349ae20413112e6fa4e89a97ea20a9eeee64b55d39a2192992a274fc1a836ba3c23a3feebbd454d4423643ce80e2a9ac94fa54ca49f" \
        "Short lowercase alphabetical sequence hash"]

    :set res [$RunTestCase $res $GetSha512Sum "message digest" "nothing" "nothing" \
        "107dbf389d9e9f71a3a95f6c055b9251bc5268c2be16d6c13492ea45b0199f3309e16455ab1e96118e8a905d5597b72038ddb372a89826046de66687bb420e7c" \
        "Standard spaced alphabetical phrase hash"]

    :set res [$RunTestCase $res $GetSha512Sum "1234567890" "nothing" "nothing" \
        "12b03226a6d8be9c6e8cd5e55dc6c7920caaa39df14aab92d5e3ea9340d1c8a4d3d0b8e4314f1f6ef131ba4bf1ceb9186ab87c801af0d5c95b1befb8cedae2b9" \
        "Numeric sequence data hash validation"]

    :set res [$RunTestCase $res $GetSha512Sum "admin" "nothing" "nothing" \
        "c7ad44cbad762a5da0a452f9e854fdc1e0e7a52a38015f23f3eab1d80b931dd472634dfac71cd34ebc35d16ab7fb8a90c81f975113d6c7538dc69dd8de9077ec" \
        "Common administrative identifier string hash"]

    :set res [$RunTestCase $res $GetSha512Sum "RouterOS" "nothing" "nothing" \
        "f4f9a19c422b426df2456e6d3d173f729f08e6ef5dd88b8ecaa88f8fe8473492a38fb7e2b5e2195d1a8a9d3f7925732ef6ef82b7f66c9af06d3c23aaa25698fc" \
        "Mixed case application specific string hash"]

    :set res [$RunTestCase $res $GetSha512Sum "A" "nothing" "nothing" \
        "21b4f4bd9e64ed355c3eb676a28ebedaf6d8f17bdc365995b319097153044080516bd083bfcce66121a3072646994c8430cc382b8dc543e84880183bf856cff5" \
        "Single uppercase character string hash"]

    # Standard SHA-512 test vectors

    :set res [$RunTestCase $res $GetSha512Sum "abcdefghijklmnopqrstuvwxyz" "nothing" "nothing" \
        "4dbff86cc2ca1bae1e16468a05cb9881c97f1753bce3619034898faa1aabe429955a1bf8ec483d7421fe3c1646613a59ed5441fb0f321389f77f48a879c7b1f1" \
        "Complete lowercase alphabet hash"]

    :set res [$RunTestCase $res $GetSha512Sum "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789" "nothing" "nothing" \
        "1e07be23c26a86ea37ea810c8ec7809352515a970e9253c26f536cfc7a9996c45c8370583e0a78fa4a90041d71a4ceab7423f19c71b9d5a3e01249f0bebd5894" \
        "Uppercase lowercase and digit sequence hash"]

    :set res [$RunTestCase $res $GetSha512Sum "12345678901234567890123456789012345678901234567890123456789012345678901234567890" "nothing" "nothing" \
        "72ec1ef1124a45b047e8b7c75a932195135bb61de24ec0d1914042246e0aec3a2354e093d76f3048b456764346900cb130d2a4fd5dd16abb5e30bcb850dee843" \
        "Long numeric sequence validation hash"]

    # Case sensitivity

    :set res [$RunTestCase $res $GetSha512Sum "hello" "nothing" "nothing" \
        "9b71d224bd62f3785d96d46ad3ea3d73319bfbc2890caadae2dff72519673ca72323c3d99ba5c11d7c7acc6e14b8c5da0c4663475c2e5c3adef46f73bcdec043" \
        "Lowercase word hash"]

    :set res [$RunTestCase $res $GetSha512Sum "Hello" "nothing" "nothing" \
        "3615f80c9d293ed7402687f94b22d58e529b8cc7916f8fac7fddf7fbd5af4cf777d3d795a7a00a16bf7e7f3fb9561ee9baae480da9fe7a18769e71886b03f315" \
        "Capitalized word hash"]

    :set res [$RunTestCase $res $GetSha512Sum "HELLO" "nothing" "nothing" \
        "33df2dcc31d35e7bc2568bebf5d73a1e43a0e624b651ba5ef3157bbfb728446674a231b8b6e97fa1e570c3b1de6d6c677541b262ac22afda5878fa2b591c7f08" \
        "Uppercase word hash"]

    # Repeated character sequences

    :local testStr ""
    :for i from=1 to=32 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "020089a47cb0761c222c323aec2bdecdaa7a0d0ec094cda8c5755ba26844453c25b37e4bc98aab8adc55c9da75bcd83af62905d62e9044a5d64cd93d93b54b34" \
        "32 repeated lowercase character hash"]

    :set testStr ""
    :for i from=1 to=32 do={
        :set testStr ($testStr . "b")
    }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "e10057ee50ff8c3d41aa451027330cb4fd67a8198932c1c72d8767035f4ad198cf0b05919e319089316e93f3b97b15d4ffc0a7df6c9712c3ff928263f2ad2e81" \
        "32 repeated b character hash"]

    # Special characters

    :set res [$RunTestCase $res $GetSha512Sum ("!@#\$%^&*()") "nothing" "nothing" \
        "138fad927473f694c3a02cca61008e52572bd19ce442f20e139b6f09157b97157fd71946fedfec2381b7e33618afe5f7c24a873ed1efe416978acfc434503614" \
        "Common punctuation character sequence hash"]

    :set res [$RunTestCase $res $GetSha512Sum ("~`[]{}|\\:;") "nothing" "nothing" \
        "a2573afa7c6263baddff15cb18968cfa7a4c9f818a3f8edc360e50598c83924c0bfc8cb86799665aaec228c152a913616542ea700daa77884dc59a8b53e04f30" \
        "Mixed punctuation character sequence hash"]

    # Short message packing boundaries

    :set testStr ""
    :for i from=1 to=2 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "f6c5600ed1dbdcfdf829081f5417dccbbd2b9288e0b427e65c8cf67e274b69009cd142475e15304f599f429f260a661b5df4de26746459a3cef7f32006e5d1c1" \
        "Two-byte message packing validation"]

    :set testStr ""
    :for i from=1 to=3 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "d6f644b19812e97b5d871658d6d3400ecd4787faeb9b8990c1e7608288664be77257104a58d033bcf1a0e0945ff06468ebe53e2dff36e248424c7273117dac09" \
        "Three-byte message packing validation"]

    :set testStr ""
    :for i from=1 to=4 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "1b86355f13a7f0b90c8b6053c0254399994dfbb3843e08d603e292ca13b8f672ed5e58791c10f3e36daec9699cc2fbdc88b4fe116efa7fce016938b787043818" \
        "Four-byte message word boundary validation"]

    # SHA-512 official NIST / FIPS test vectors

    :set res [$RunTestCase $res $GetSha512Sum "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq" "nothing" "nothing" \
        "204a8fc6dda82f0a0ced7beb8e08a41657c16ef468b228a8279be331a703c33596fd15c13b1b07f9aa1d3bea57789ca031ad85c7a71dd70354ec631238ca3445" \
        "NIST 56-byte SHA-512 test vector"]

    :set res [$RunTestCase $res $GetSha512Sum "abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmno" "nothing" "nothing" \
        "90d1bdb9a6cbf9cb0d4a7f185ee0870456f440b81f13f514f4561a08112763523033245875b68209bb1f5d5215bac81e0d69f77374cc44d1be30f58c8b615141" \
        "NIST 64-byte SHA-512 test vector"]

    # SHA-512 1024-bit block boundaries

    :set testStr ""
    :for i from=1 to=111 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "fa9121c7b32b9e01733d034cfc78cbf67f926c7ed83e82200ef86818196921760b4beff48404df811b953828274461673c68d04e297b0eb7b2b4d60fc6b566a2" \
        "111-byte SHA-512 padding boundary hash"]

    :set testStr ($testStr . "a")
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "c01d080efd492776a1c43bd23dd99d0a2e626d481e16782e75d54c2503b5dc32bd05f0f1ba33e568b88fd2d970929b719ecbb152f58f130a407c8830604b70ca" \
        "112-byte SHA-512 length-field boundary hash"]

    :set testStr ($testStr . "a")
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "55ddd8ac210a6e18ba1ee055af84c966e0dbff091c43580ae1be703bdb85da31acf6948cf5bd90c55a20e5450f22fb89bd8d0085e39f85a86cc46abbca75e24d" \
        "113-byte SHA-512 padding overflow hash"]

    # 127 / 128 / 129 bytes

    :set testStr ""
    :for i from=1 to=127 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "828613968b501dc00a97e08c73b118aa8876c26b8aac93df128502ab360f91bab50a51e088769a5c1eff4782ace147dce3642554199876374291f5d921629502" \
        "127-byte SHA-512 block boundary hash"]

    :set testStr ($testStr . "a")
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "b73d1929aa615934e61a871596b3f3b33359f42b8175602e89f7e06e5f658a243667807ed300314b95cacdd579f3e33abdfbe351909519a846d465c59582f321" \
        "128-byte exact SHA-512 block hash"]

    :set testStr ($testStr . "a")
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "4f681e0bd53cda4b5a2041cc8a06f2eabde44fb16c951fbd5b87702f07aeab611565b19c47fde30587177ebb852e3971bbd8d3fd30da18d71037dfbd98420429" \
        "129-byte SHA-512 block overflow hash"]

    # Long multi-block messages

    :set testStr ""
    :for i from=1 to=512 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "0210d27bcbe05c2156627c5f136ade1338ab98e06a4591a00b0bcaa61662a5931d0b3bd41a67b5c140627923f5f6307669eb508d8db38b2a8cd41aebd783394b" \
        "512-byte four-block SHA-512 message hash"]

    :set testStr ""
    :for i from=1 to=1024 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "74b22492e3b9a86a9c93c23a69f821ebafa429302c1f4054b4bc37356a4bae056d9ccbc6f24093a25704faaa72bd21a5f337ca9ec92f32369d24e6b9fae954d8" \
        "1024-byte eight-block SHA-512 message hash"]

    :set testStr ""
    :for i from=1 to=1025 do={
        :set testStr ($testStr . "a")
    }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "c904641aa423a803e0b961e3993baf8659e5da958fa89c641bbb582c804fe0aa149cfa0afec16f5d15474ee46ff8611441d87dff157834caade9e1aa40bd898f" \
        "1025-byte SHA-512 multi-block overflow hash"]

    # All 256 possible byte values

    :local allChars ""

    :for i from=0 to=255 do={
        :set allChars ($allChars . [$DecToChar $i])
    }

    :set res [$RunTestCase $res $GetSha512Sum $allChars "nothing" "nothing" \
        "1e7b80bc8edc552c8feeb2780e111477e5bc70465fac1a77b29b35980c3f0ce4a036a6c9462036824bd56801e62af7e9feba5c22ed8a5af877bf7de117dcac6d" \
        "All 256 byte values SHA-512 hash"]

    # High-bit bytes

    :set testStr ""

    :for i from=128 to=255 do={
        :set testStr ($testStr . [$DecToChar $i])
    }

    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "fd68692d2387e4c118cd0f3e75418a70e9e633f21df2e6fc02b193d587c74308c0a2d24e3ffeac51c6b9bf8bee3f2d833bcfefb7c63b63b0585eee518b7893b2" \
        "All high-bit byte values SHA-512 hash"]

    # 128 zero bytes

    :set testStr ""

    :for i from=1 to=128 do={
        :set testStr ($testStr . [$DecToChar 0])
    }

    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "ab942f526272e456ed68a979f50202905ca903a141ed98443567b11ef0bf25a552d639051a01be58558122c58e3de07d749ee59ded36acf0c55cd91924d6ba11" \
        "128 zero-byte SHA-512 message hash"]

    # Additional length-sensitive SHA-512 tests

    :set testStr ""
    :for i from=1 to=17 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "06ef0364617146f6200c2cbc4280202226d701c2961940f57e7b60677587c66087f23bbcffa0de8692221f9434ac9a21e6df6428377cd145e1a456e2359d2cf6" \
        "17-byte a message"]

    :set testStr ""
    :for i from=1 to=18 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "10dbd292472d3ff7279f3dac7fdb83c296bd61cbe80b0e26fbc14f871fd9771180d83879e812ec9841ba15a110e84a589c0eedfc14427c23ba56fa4fb7773de0" \
        "18-byte a message"]

    :set testStr ""
    :for i from=1 to=19 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "1d383178e64d7071e749b2d560a22abc97e6514c31e800b5cc12c6f72ad43a9a0c4ce7db246219f3dea09afae6044a484de203148cb55f1057ee37b9420073bb" \
        "19-byte a message"]

    :set testStr ""
    :for i from=1 to=20 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "d87a10a0bee363dcdf764831e807df5ee5500483c09056b38f854606f9e665566264b15af9fee8f9b84f3a7b6ddb67b92996ef790d10e899ba0758d5ab650caf" \
        "20-byte a message"]

    :set testStr ""
    :for i from=1 to=21 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "1f60925cd5271a8ec9eb49ea4bf187f6a7dbc22eeb0e2dbc89d8381d0e73dea5bff5375a6db7e49fc427cb4fdf9f7ece577037adf91decfc38f303b1cb79ad44" \
        "21-byte a message"]

    :set testStr ""
    :for i from=1 to=22 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "0ff3b2ffbda4cf938263e9449735618103a4d6a0cdeeda57367f6377d23849c3dce6851377f8f1b3d2ce3ff1dd6de0d64920d7790994782b4a8e2697e31f1900" \
        "22-byte a message"]

    :set testStr ""
    :for i from=1 to=23 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "c6020ac00b701699227ccc9355156da0ad1d521ada5949cc89dd00661725be08fea4a2519ceb1e50acdd16e7127783f7ed5bfabe5238ce0da7ad2b4174c5509a" \
        "23-byte a message"]

    :set testStr ""
    :for i from=1 to=24 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "e37ff6da226042c6fdd066c20f00e0d09c4f4dea104d8ea1fc513496ef24a0e17cd4bfb2e95781329a45d3885ca0e20f88e453dc9a4c4dc2acd0be756e3356b8" \
        "24-byte a message"]

    :set testStr ""
    :for i from=1 to=25 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "4d272d73d4000f885ad1be048b7c7f92c2a8e5a01f30a96ed82849223606ad639f73155c85a128fbd2c26d3de30fb207e57b9f7ff21bfc79e0d7f0e2fb5189dc" \
        "25-byte a message"]

    :set testStr ""
    :for i from=1 to=26 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "90cce547b76967676972c60e83944ffdc143078b6b40c722a0f2ac90d78eed0057843213076a9a7df528d0c0ebf3c00a91ae1c37f8850173fa2c03c41b6168ea" \
        "26-byte a message"]

    :set testStr ""
    :for i from=1 to=27 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "4cea8c7ef657f9177c286081f8f016adae91a131a496e939ac86060e691afba57accc08ddbc423eb9d0817725faad9554c60f314929f30e881871e8782228918" \
        "27-byte a message"]

    :set testStr ""
    :for i from=1 to=28 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "24077df741cb7ba88537d62c55fbff3ea81b603c31e6fd0d2e5d28e1a505f6192d5b2c1f98011152fef2c75901f66d489c045a4a3f98705c2b244c004f1579d4" \
        "28-byte a message"]

    :set testStr ""
    :for i from=1 to=29 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "2af97e464526c024ef466db4616559919b769b350b7f6830ecfa5ffdeacd6eb570daf0ed25c0c56b194119f15247f63f5b94b54e01283b4b7a832586acac9e09" \
        "29-byte a message"]

    :set testStr ""
    :for i from=1 to=30 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "abd9c33f8c791b27dd614e80ad77f1ff33c2621663b4dcbe5a88417a8b95b8d6788a9320678b589aa5b405897b2113523df1defa304953ea2ae1a229f2736450" \
        "30-byte a message"]

    :set testStr ""
    :for i from=1 to=34 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "c1de14e1a09b03c688bd568ff4b4fa086baed2181d0d99a219fb937484ba67f093efe36966b0ea5209dadb6ef4f67c2d1f753d49c083a6241d2ab4557509404e" \
        "34-byte a message"]

    :set testStr ""
    :for i from=1 to=35 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "cbb50e7e8a14cb9df08642609b6d737302d78cdcff74e1f53e895ae4a7cb093a571364dbbc2797962f54366ef65ead1c41a44ffe2ab0d56b7ae01e99a7a4e6fb" \
        "35-byte a message"]

    :set testStr ""
    :for i from=1 to=36 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "85a564722dbefd268ed2e2e70fb377306c207a9c7edb634adcd79b8829aaad700c3a26cce44eba99aff46c4349f5e5056a87fcd2b63dd08b8b7b1f2f3ea06d6b" \
        "36-byte a message"]

    :set testStr ""
    :for i from=1 to=37 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "ae77859a42c40e3973aa42bc8fbe8713444f65173580507d7c4bcc7c85d7f8c93204f433d506e912504ea37c766af17e649bdf6c8356f6e8e65bf4e9321987cb" \
        "37-byte a message"]

    :set testStr ""
    :for i from=1 to=38 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "5b7c791e8018b14752ca7b91386d3ddbd3f9307a69ca71d977e274171aa5cae0b1a03960e842ca05fc0b95205a243fc8b28c36e4dd60ff000a47fb63547e6a0c" \
        "38-byte a message"]

    :set testStr ""
    :for i from=1 to=39 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "f140bd9a11c309eb9da6ae1c8360cf2bc952a41a9ff228c066c0811df508313f59f1b6e6ffc6d14ef967f477c69463974aefd78d1c1dec9d8d35ff0c81dc29e8" \
        "39-byte a message"]

    :set testStr ""
    :for i from=1 to=40 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "e411795f8b2a38c99a7b86c888f84c9b26d0f47f2c086d71a2c9282caf6a898820e2c1f3dc1fa45b20178da40f6cb7e4479d3d7155845ed7a4b8698b398f3d0c" \
        "40-byte a message"]

    :set testStr ""
    :for i from=1 to=41 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "9178f65d74628c56ce3ace5b9ae7ecb84fc8a840ae33367a9c5534e6556301dc4fea4927d82289483496c39b929afb4a4ea92ded82c02057a7b8029828d8fb8d" \
        "41-byte a message"]

    :set testStr ""
    :for i from=1 to=42 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "e11e1d056266f561bf3a9dede38228700e59971b3be992fea66a687887441976d8b29193707211dfb94dd1f7918473c3e99ff48a7c91068a1aaf7054febb9e2d" \
        "42-byte a message"]

    :set testStr ""
    :for i from=1 to=43 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "acbaf243155ab6ca5f44c13061757fa060acbc5cf43d996b4f47209c22bf70c29af8dbc5c0a68ca45e42142db1540d2db70f6f27a917a3019dc92dadd0f639d6" \
        "43-byte a message"]

    :set testStr ""
    :for i from=1 to=44 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "647b6deadb5aeb56e4087414fe2a76d6f57083dd6303a19e152445d108dc2bcd17926981d500b19b913b36a3b343b2e6781c805c1897664a218a2cfecc6a5238" \
        "44-byte a message"]

    :set testStr ""
    :for i from=1 to=45 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "3ca97cdefcc384485ec2b6bebffe63d98f5675132a8b43d1f38bad4ff1982264fc4876ec637e918f855d855945b9b84eb82386bc6fc1e92695ec623001f8ddd1" \
        "45-byte a message"]

    :set testStr ""
    :for i from=1 to=46 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "7b549433b4ef39abb90dcd3eb90c63562b7f3daa056670b2f712ebb7e9e78adfe7423e4b39810c1109fb640e84d32047468b155fe342d13e7f4d7ee019fa5922" \
        "46-byte a message"]

    :set testStr ""
    :for i from=1 to=47 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "ec1d753e2280b8136b686ec81b03b3f8a7f98152868e3a68f0a2c456082c2faaa93c39ad573a6d21f4a3350df602249dc89ad28620d27ecc1d9e1f258badcd04" \
        "47-byte a message"]

    :set testStr ""
    :for i from=1 to=48 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "bd582a787a21036df7049d501879977625601527d7ddd6f707463cb8b3839fbedbe233b8e69f1696d0e82b168d3491a3dbb6005b6224c198601dafbd50e14365" \
        "48-byte a message"]

    :set testStr ""
    :for i from=1 to=49 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "4b4ff3bc763a976c16afdd8082efc7a5c98d60342f0ed5a654f567dacbc6414833e60ed1d6770bd42638fdae605c69be0219532125a186609f0825376ab59e45" \
        "49-byte a message"]

    :set testStr ""
    :for i from=1 to=50 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "bdba173e58132092b0aa67ea5080f247e5b3710630a789c519b311f3848588f0bac8db3091ff8fd16875601636bef625e43b3d82cb51eb6693cdd1b2a5c872b8" \
        "50-byte a message"]

    :set testStr ""
    :for i from=1 to=51 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "78a0eb5d7c0b05284056e1f19cbb42a99470bc81de4f9bc48708d28c5a877626e69167c58d4e840a7aa699bc6dddd972564d84ea502b41d83878e98e68f83c81" \
        "51-byte a message"]

    :set testStr ""
    :for i from=1 to=52 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "a45021322d3f30747b3ceb7c1b1975ac4698984be76915f82cdeefe769f115d9dc5c70549e897b0ab8d5d61fc9e73ad1f7f49db39bb4e1298ac833d290eb1d04" \
        "52-byte a message"]

    :set testStr ""
    :for i from=1 to=53 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "0b08accaae7044e54074fdcb7404a10c0703144d4499a644d9cfc60f973dc27dcdc65ac31750f7407ba96d025fb699e64ddcd1acd0dabafeeafccb5733225d3b" \
        "53-byte a message"]

    :set testStr ""
    :for i from=1 to=54 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "07a2200290a2b7423a94f71892554b17196e2301e2e446ce09f65abcb45523268274128038925489671af9b899747b80e35a0a1b8613ecfb44e6be3152a2fd93" \
        "54-byte a message"]

    :set testStr ""
    :for i from=1 to=58 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "2282084c042e92d7ba1a9e1ee5527762e91c4ffee7a8676c4a4a0facefad352bed2d3c322368cfe813186084c5386e9f22f803dfe0a1b424cab3e0a95a6dc3f9" \
        "58-byte a message"]

    :set testStr ""
    :for i from=1 to=59 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "fd4eaf2071e8d9cf36688c3be714f5e363a5b4932f509914c613d1b8987d188e82cdd12b6ab07ea2f676fad1789275ef37253260a817a61079bc0ea567ee094a" \
        "59-byte a message"]

    :set testStr ""
    :for i from=1 to=60 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "5ac08e89d884de3f086c60e8f36e754cf0ae9be2f018a87b7f71b15c81356410077eaa075010eb48959783ba490dc7c9fec53573848d8929bd5fc0574552f58f" \
        "60-byte a message"]

    :set testStr ""
    :for i from=1 to=61 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "0202004b03bf7be513c96ef3fa6e48fce6e02f858d3bd95edba5adbdce60b2d7a4aa8700de15fc421b5e6847d8fb8be1bd24acd16314cfd94f0fa69ff6d637b4" \
        "61-byte a message"]

    :set testStr ""
    :for i from=1 to=62 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "9814d48ae1bfd731b32f0a829f20507ec9bd6b77609053718f7e2053b53c7a264bbab6a96d3d54a7f9a736570d11b1f99afb1735149f43cfee9b6f87886d3ff6" \
        "62-byte a message"]

    :set testStr ""
    :for i from=1 to=66 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "f2f1cb2b1da21f7df43034baf8ec6bc992a46a022a40f81339240fdae572dbdf34fcf26e97cabc0e001c0aa65607b45585d107c48d676d6e2f389fd801d1fed7" \
        "66-byte a message"]

    :set testStr ""
    :for i from=1 to=67 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "1b049c5022acb0a6f886cb607629db83dee7ee8f623f8f0fcf352b8f5052036cc7e992e9f79bc424173abb07df8ccfb058f13cfe2a14925a1bb67f4447dd8929" \
        "67-byte a message"]

    :set testStr ""
    :for i from=1 to=68 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "6c450032dd6b928bdb327b9892d15808163d314aeff37089380ca01ee4b1c8db739f71de29446c385fc8e0f12482ccb04ca1572e243affc7d77ed7bbc083be0d" \
        "68-byte a message"]

    :set testStr ""
    :for i from=1 to=69 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "73fa82cfc129fb937094b53346e04ff29e44c67250f6952b63ef561bc7cc1169fd94368a252ae408f496c17684145d65cd46ec9c5a03eb59ecc35f6a1d2fc159" \
        "69-byte a message"]

    :set testStr ""
    :for i from=1 to=70 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "d7ef283e6194befc2498bbced7f58bdf60cfcf10011fc5817b69cb13d63725017aa1e632ea3c609f6a5eb8a057ddb82953538f3e2a738262a11ddcd47f13752d" \
        "70-byte a message"]

    :set testStr ""
    :for i from=1 to=71 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "216d4ffba1e94e8f281b06feb558346eeb0ae567c0a1d0c56ba2df704f45b2a6e6d91f97c5c00ebbcdfeb14b438bd9e56f2eb36ca64d22392520f3496f28fef5" \
        "71-byte a message"]

    :set testStr ""
    :for i from=1 to=72 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "7e076f0892677d21072e99258203151146d4bc78ad6ed68edc939ba080c473ab66b10d38834e33abde71830dbd8529d895c7ea5f5773f1457d7c71bc3824b7c8" \
        "72-byte a message"]

    :set testStr ""
    :for i from=1 to=73 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "1a3d403b46c595edfb71d10b4cb9e1b9ce4e44e28db6ba2a0334195816b85e6eba147bc6160864a0fe28166f99148476893a031a38a814e7136497296865f3c9" \
        "73-byte a message"]

    :set testStr ""
    :for i from=1 to=74 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "4c4c8dcd6ba88f47a51df4dabdf227c335d70d5f4941b76e698536693e53c50241ef0264ea6f6dc5527485ddbe7a76900405158e32fef5ed184919943148da67" \
        "74-byte a message"]

    :set testStr ""
    :for i from=1 to=75 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "8ea2d14c839946461666ab0a5966a10886e29d0a890104b123bb94d0af9011d8a961681fb95df98d00d5d351985f61f2e2eba2d91fd8032566b856d8408a09b0" \
        "75-byte a message"]

    :set testStr ""
    :for i from=1 to=76 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "c642ba36e76cc1660c342d163fb32e4be8482072e641dd6b3662c447ecbc24f1b5e16ad4b83eed093c6f5999f1b2a0086fc23526cef9241a5a052c720bb5afde" \
        "76-byte a message"]

    :set testStr ""
    :for i from=1 to=77 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "b9451e8c39c4276c2192939d49cbcb2b85a048e4f38bb5d3282e24c417de893ac2ff0acdef20036ed4deddbb526f992cd56f992aaba93d4edd3a628a4e53c811" \
        "77-byte a message"]

    :set testStr ""
    :for i from=1 to=78 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "9a8c06cf6123391e9ee4d2441b7e534fc9551c242fb2b96fad45a7210edc010c36704b9ca1a07e935e6ff1413768e2f27726b213b16961633341ea82d75c5df3" \
        "78-byte a message"]

    :set testStr ""
    :for i from=1 to=79 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "54b998867e8ac0d3eebcbf2252c107ad6dc5b557db5b7cb65a147475db99831011878784a62678a6fada687705ef68d048047f05b51db9c09168c4a7ad877036" \
        "79-byte a message"]

    :set testStr ""
    :for i from=1 to=80 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "cb8d0d18db405d9d964ab61d1a5c00024df3805a329bf1500bec74d3ec1f1d0574da0b86153c9d8e317603bdb09e46d54d44551992a2464f0335a8398a2f2aee" \
        "80-byte a message"]

    :set testStr ""
    :for i from=1 to=81 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "2fe6df89dcac80c7a03c2bc39633c12ae2898019117aacf77e490fa54cb8deb34a0d29ce778ee4f674831921853a15b541773486d5ac785163744e6d24ba388d" \
        "81-byte a message"]

    :set testStr ""
    :for i from=1 to=82 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "c3e410354f6f890d0f3027805da471340f91db2a858501059124d3175eb7d637ca3637f7f95bafde0d74d026be7bf086e48931e299d68edc43e0a7ac4eac75c4" \
        "82-byte a message"]

    :set testStr ""
    :for i from=1 to=83 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "107068fb436d658c0a96157316af41d323e582ea9c81146933ead563bf2c2a05b2c77ceeef57c01cd09ec28f6507238e930b1b7241d731f83194440f9256e5a6" \
        "83-byte a message"]

    :set testStr ""
    :for i from=1 to=84 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "62b5337f5be290d028dc41dde08682ed7b0a7a842eae36dc6f7220e220012aeca98b2dac28325d1f78beef84352689c07c3a45f549e98ba908b010abceca9978" \
        "84-byte a message"]

    :set testStr ""
    :for i from=1 to=85 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "6b6f3ac1316d9e8d1505ad163b70077df1df92568139721b32c23e5d84dc2fd742a4bad56bf0efacb3f3e63bbfb08a829b16df8cc1799eb199cd5d56be2b9d52" \
        "85-byte a message"]

    :set testStr ""
    :for i from=1 to=86 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "bf8ed43d3aeebeb9b00d91013fbbb463b2f4b13e7ffc42741aeb9f0190a91b0401bb4fac68cc009d314287876c54d2f18891e6eee86fbe7125171559be6a03d7" \
        "86-byte a message"]

    :set testStr ""
    :for i from=1 to=87 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "056ffe9a8b3a346abb92cf36efb74417748a044c4ca07f94e7bb076eeafa67073a85fcc1b17e7953138f304bbea7d0592e910e55b489e22c9015dc4e04ba76dc" \
        "87-byte a message"]

    :set testStr ""
    :for i from=1 to=88 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "a945652aabf28d5ed6bb284a35fd4296a9a0ddebc81bf59991759ecaa7fb95a59628cf1ae75c88177fa3993e0cd0f138a807cdc01d17ca3922817ad1dc1c39e7" \
        "88-byte a message"]

    :set testStr ""
    :for i from=1 to=89 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "bb4ec00ac4a82ed71af3936559c5940582218da063554c6f3efbb6d67cc808a2d6dbf088d0f371a4a1259efb1f1edeefa8093cab25551519d7ac6142711e50fe" \
        "89-byte a message"]

    :set testStr ""
    :for i from=1 to=90 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "3a60fa8bede0f822c5dea75eff151ed5841d11b301c474a13571aff2dd0e216b4bc072b9ce409a70c6e6ff35bcae2f0950880d943f95775dd8f54d94b12d47c3" \
        "90-byte a message"]

    :set testStr ""
    :for i from=1 to=91 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "bed8ac47aef0271fe40227247ddcdfd6b4885effeba3042f34b6fd525ab56cbdf72050cb71b1d42ae0ee1c548b36668b9297279d661380dffa39e66aa2959f99" \
        "91-byte a message"]

    :set testStr ""
    :for i from=1 to=92 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "dfecce5852f67e858304fc5dc0c15cb29e28c69af4e2c117d333ea46d2ef2b0379a983507bc16e827b86c2433404159b759de91eb9ae975f338bacf38ad20371" \
        "92-byte a message"]

    :set testStr ""
    :for i from=1 to=93 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "51585d172675d427009ea1658ac2a4d67a600e65034cb7f8eb34a39add704b67ae0a2798b7d7e7a16ee0f6902a165a0646cd9fe1cc777a07c6bfa14028c8eec8" \
        "93-byte a message"]

    :set testStr ""
    :for i from=1 to=94 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "9e4246d4d3725a67a909dd1a4f06c627627942c0bb31eb4c614cab842e6bfb9faa7e8938575a2402832ac353a6fb47f4918b31d754eb9764e714f6925462b54e" \
        "94-byte a message"]

    :set testStr ""
    :for i from=1 to=95 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "89e0446c3ff5a04b6d707ef43a77e2b349791f402930dbdb74bbab73d5215e294146ba7bd2fa269aee38564ef11a9ccaf5278f9e82687126dcf20d481d470617" \
        "95-byte a message"]

    :set testStr ""
    :for i from=1 to=96 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "39ba3c74b23cb7deffb5d59624e320c08692637057daaaeea4d847e1d3b6a2ce6895ff3c609d57da490484b030ed231d5bdfafcfe264bd3d91cddb39c2d036ab" \
        "96-byte a message"]

    :set testStr ""
    :for i from=1 to=97 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "db3a1fb5909f50e02e1626616247de6867e9e332d0eeef4650367cf0058f4764eb4a3869d3931b5ef6fc7a044a868b5fa894462df15c3954e88cd70c9a1de1b2" \
        "97-byte a message"]

    :set testStr ""
    :for i from=1 to=98 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "86497b815f64702e2ac6aca1f1d16f7159b4f0b34f6e92a41e632982a7291465957e0ef171042b9630bb66c6e35051613f99bdc95c371eeb46bff8c897eba6e9" \
        "98-byte a message"]

    :set testStr ""
    :for i from=1 to=99 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "21883a9b2ffa353c93fea49ea8b92be22797e6e8b360ebac8ed894b702766458a825adf67d9561d6758f5f9cc3aec7a4b2e4464a08e6959029dbc0b2f3fc6105" \
        "99-byte a message"]

    :set testStr ""
    :for i from=1 to=100 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "70ff99fd241905992cc3fff2f6e3f562c8719d689bfe0e53cbc75e53286d82d8767aed0959b8c63aadf55b5730babee75ea082e88414700d7507b988c44c47bc" \
        "100-byte a message"]

    :set testStr ""
    :for i from=1 to=101 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "2327e3b2946432dd2f4bce390ca652ec5e90f44fced0e921f612cf6d594cfc5e21b56e30a30dc0157e2c37a59cd37951f20cb9e2bc2d815a2676c01c2f827d51" \
        "101-byte a message"]

    :set testStr ""
    :for i from=1 to=102 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "ec90d76ee1a1643126f53609a2721ad4a130c57d4dd0416a5d1b0bc43419ed6b3b0e82e0ff5eb76e94accfacb8bf72d7c92b622a0842d9a5b8b6e40fa2fc5231" \
        "102-byte a message"]

    :set testStr ""
    :for i from=1 to=103 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "48e257ba5ef0c4b0b9769d26d5990d87f058430e368802c1f9a47195a6fa23ede9bbadc4c46ef2a8480cbfa0ced25dad522ca1752a66d5b43a72486f82c7b934" \
        "103-byte a message"]

    :set testStr ""
    :for i from=1 to=104 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "e4f39bcd76fe94bfa84b31b0b9f3d2fe065b1e01ff2c3c0cd6f26b942f3c73a35031b9ecb4d82418a52892dabb459b27f0ba04af5e90636edf0b2caaa2d7906a" \
        "104-byte a message"]

    :set testStr ""
    :for i from=1 to=105 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "3b6dd73c9552f2381107bf206b49c7967fdc5f5011d877d9c576bb4da6d74fbbabf46a1105242d7c645978e54c0b44adaf06d9f7aa4703e8a58829f6d87c5168" \
        "105-byte a message"]

    :set testStr ""
    :for i from=1 to=106 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "470edb01e9dc9db187acdc9fa594e35b40831f9ddf76309d4a99a7aef1f0d9f79b5a4c9a22a38aeca3a1c2d6ceaeb603899577a30643a97872717c025a9a4fdc" \
        "106-byte a message"]

    :set testStr ""
    :for i from=1 to=107 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "8cfcdd655481cca50730fe51ee985e9b51946f1345cb6a1801e5e0ed64ef979f431d5a7c3bd2a479d6d82e354210741956d194ee0febbc132b35907f4e2be32f" \
        "107-byte a message"]

    :set testStr ""
    :for i from=1 to=108 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "a53d93726f1ba688a57267326473eceddc4ccf992d5c53429ca3edd4b122b4fe0b0568887d65c220cbac93fc4f612f97a09eb95e9f903409c78a22eee4fa1781" \
        "108-byte a message"]

    :set testStr ""
    :for i from=1 to=109 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "0cda6b04d9466bb7f3995c16732e1347f29c23a64fe0b085fadba0995644cc5aa71587423c274c10e09518310c5f866cfaceb229fabb574219f12182eb114182" \
        "109-byte a message"]

    :set testStr ""
    :for i from=1 to=110 do={ :set testStr ($testStr . "a") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "c825949632e509824543f7eaf159fb6041722fce3c1cdcbb613b3d37ff107c519417baac32f8e74fe29d7f4823bf6886956603dca5354a6ed6e4a542e06b7d28" \
        "110-byte a message"]

    # 128-byte patterns

    :set testStr ""
    :for i from=1 to=128 do={ :set testStr ($testStr . "A") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "6486a74d95f54812a76071f6c6344ab6d34df3da685ec70dc78d9c5804b4ee3c449d9e68a6b52491f8275b838c2cd9102c3c223a620bbee2671edbff2611594e" \
        "128-byte A pattern"]

    :set testStr ""
    :for i from=1 to=128 do={ :set testStr ($testStr . "B") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "12e363f5996a10b81d848c437ddc08a6d9bde2ff4596341a694de21b9df14578ba07cb7cdfbab1fdc54617ecfc6fccaa0203352e0faa39b38cca6c710b4e6779" \
        "128-byte B pattern"]

    # Multi-block tests

    :set testStr ""
    :for i from=1 to=128 do={ :set testStr ($testStr . "A") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "6486a74d95f54812a76071f6c6344ab6d34df3da685ec70dc78d9c5804b4ee3c449d9e68a6b52491f8275b838c2cd9102c3c223a620bbee2671edbff2611594e" \
        "128-byte A multi-block test"]

    :set testStr ""
    :for i from=1 to=128 do={ :set testStr ($testStr . "B") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "12e363f5996a10b81d848c437ddc08a6d9bde2ff4596341a694de21b9df14578ba07cb7cdfbab1fdc54617ecfc6fccaa0203352e0faa39b38cca6c710b4e6779" \
        "128-byte B multi-block test"]

    :set testStr ""
    :for i from=1 to=256 do={ :set testStr ($testStr . "A") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "b7828faae9bc9fa289a07a1be3f87cdc473014ea2697e5b1365b1b862b5c304c61390cbb795bfdd5ea67dd3f72ecf0976c27765729d2da5e630abca196ab29b8" \
        "256-byte A multi-block test"]

    :set testStr ""
    :for i from=1 to=256 do={ :set testStr ($testStr . "B") }
    :set res [$RunTestCase $res $GetSha512Sum $testStr "nothing" "nothing" \
        "708d6d0c7bc622e70085bbc855e77bcc6d32ae3618b0540f00e7ed6996d01c69666d4e3918d0d96400c40722e0f63287210928cd9cf4816364fad3ff54e97b27" \
        "256-byte B multi-block test"]

    # Alternating patterns

    :set res [$RunTestCase $res $GetSha512Sum "AA" "nothing" "nothing" \
        "282154720abd4fa76ad7cd5f8806aa8a19aefb6d10042b0d57a311b86087de4de3186a92019d6ee51035106ee088dc6007beb7be46994d1463999968fbe9760e" \
        "Alternating pattern: AA"]

    :set res [$RunTestCase $res $GetSha512Sum "55" "nothing" "nothing" \
        "4774b6224b8e98b96b658092bee32c88c41b1a8c80dcfd7e1fdffc7be59c5f72eae3aecac37b0c7398154489066b0b022240a68daf4432849fabe75768faaf5e" \
        "Alternating pattern: 55"]

    :set res [$RunTestCase $res $GetSha512Sum "AA55" "nothing" "nothing" \
        "328ebd94d145f9248e1990db8d964404e9846783e3715f94c2ef0d551dd975c2c143de30118d7d4909af1a87e22ef7d8c22e8138b1fdf0f1e41f3685025fbb22" \
        "Alternating pattern: AA55"]

    :set res [$RunTestCase $res $GetSha512Sum "55AA" "nothing" "nothing" \
        "0d9ccf12e02adaccf0f77632b2b7335f9a744641a948c80f6561b35c4513c2d91e57724bb1cf078948f8e88565e4417a3680cc5b5615625456616903a2e49850" \
        "Alternating pattern: 55AA"]

    # High-bit binary patterns

    :set res [$RunTestCase $res $GetSha512Sum ("\80") "nothing" "nothing" \
        "dfe8ef54110b3324d3b889035c95cfb80c92704614bf76f17546ad4f4b08218a630e16da7df34766a975b3bb85b01df9e99a4ec0a1d0ec3de6bed7b7a40b2f10" \
        "High-bit binary pattern 1"]

    :set res [$RunTestCase $res $GetSha512Sum ("\FF") "nothing" "nothing" \
        "6700df6600b118ab0432715a7e8a68b0bf37cdf4adaf0fb9e2b3ebe04ad19c7032cbad55e932792af360bafaa09962e2e690652bc075b2dad0c30688ba2f31a3" \
        "High-bit binary pattern 2"]

    :set res [$RunTestCase $res $GetSha512Sum ("\80\FF") "nothing" "nothing" \
        "8fc8d971b12fb6e93acb0bf84903aaafdabb22af54929ca067f6f3812565a138af18e4f62a38d7cf546364c53ae15b180f5964a00236794ce5c5c7fe04b690ac" \
        "High-bit binary pattern 3"]

    :set res [$RunTestCase $res $GetSha512Sum ("\FF\80") "nothing" "nothing" \
        "3e024b9962d3f0661a56b87ae867499a013074b3cc90dee7809484efb93a764339c494f28eacbdeed0414cb647d1836cab83939de9aa8fe2f12ae5698230c496" \
        "High-bit binary pattern 4"]

    :set res [$RunTestCase $res $GetSha512Sum ("\80\80\80\80\80\80\80\80") "nothing" "nothing" \
        "0736265d6efc33b0f2170d63040e7114ddc9a06a78b9a4f8818b1b628d845d69c9b516dc423fcaa2052411075a853c46be8926aa0183fe829884c214e6156761" \
        "High-bit binary pattern 5"]

    :set res [$RunTestCase $res $GetSha512Sum ("\FF\FF\FF\FF\FF\FF\FF\FF") "nothing" "nothing" \
        "d0e784dd6dfb1a1f64da68379c349e5d7b5354d2a7312694b9d736b1410f408f5d5fd50924acef6cc6d78653917972bc0551fa11712de9ccdfbe4ef988962bf0" \
        "High-bit binary pattern 6"]

    :set res [$RunTestCase $res $GetSha512Sum ("\80\FF\80\FF\80\FF\80\FF") "nothing" "nothing" \
        "c58626e850ab8d7b50b20797d68f86fc89b866d0607d00e1c5f4cb6fce9506ce2b0b9ce79cdccdefc354a694cf562b5693635f6bf8db4c560700c102ab2235d3" \
        "High-bit binary pattern 7"]

    :set res [$RunTestCase $res $GetSha512Sum ("\FF\80\FF\80\FF\80\FF\80") "nothing" "nothing" \
        "5f8c2d8be68f8e5fb31f97012f6ca4a0a6b571a33ff9a2671f406f32011bcab618b5837e811bbc914f7f2f14cbeae6eeba7fce1ea9775cce924f13df5956f079" \
        "High-bit binary pattern 8"]

    # Signed int64 boundary patterns

    :set res [$RunTestCase $res $GetSha512Sum ("\7F\FF\FF\FF\FF\FF\FF\FF") "nothing" "nothing" \
        "f48eaadddca1083f42f340f4ad0ab5bf7e50d9f7b6fec01807e12cef9bb0c014506c6393155095bf4ea4963f409b8db58fb17f0f2c5887824b53aa7cc69dc8b3" \
        "Signed int64 boundary pattern 1"]

    :set res [$RunTestCase $res $GetSha512Sum ("\80\00\00\00\00\00\00\00") "nothing" "nothing" \
        "268c793058acb875e8eb1e613aff64ef78487ab8bb95baa2877647a3f7c1a326f8db76c51c19c05fbe428a75ff93edd077089d6f1bac26b1af2764f0f9783149" \
        "Signed int64 boundary pattern 2"]

    :set res [$RunTestCase $res $GetSha512Sum ("\FF\FF\FF\FF\FF\FF\FF\FE") "nothing" "nothing" \
        "f0026c02c18851dd0be531dd93f4d386b680da35c5b64c4e19069a8122b6ab1d55dd002bed2d280c25e5472d08761bad747c4ac199cc4577a0ed94250c533f09" \
        "Signed int64 boundary pattern 3"]

    :set res [$RunTestCase $res $GetSha512Sum ("\80\00\00\00\00\00\00\01") "nothing" "nothing" \
        "7ae8734ee120d1ac6717ad6de5f6d7a8ef7c010c68f2b123775691fd3f22b82232c215f9b9175422780c5f14d99ad9b4cf41c36266cb54075ddbcd9b4345aead" \
        "Signed int64 boundary pattern 4"]

    # Padding-sensitive binary patterns

    :set res [$RunTestCase $res $GetSha512Sum ("\00\00\00\00\00\00\00\80") "nothing" "nothing" \
        "019cac7ce0b5cd6dbeff1fb7ec4e323140ba3832cbadce911a6cb41ef150a71f144afe8038dff192da743a02f6bace9c3b38fa6234d8ddfe0c4c04d3cb2de9c9" \
        "Padding-sensitive binary pattern 1"]

    :set res [$RunTestCase $res $GetSha512Sum ("\80\00\00\00\00\00\00\00") "nothing" "nothing" \
        "268c793058acb875e8eb1e613aff64ef78487ab8bb95baa2877647a3f7c1a326f8db76c51c19c05fbe428a75ff93edd077089d6f1bac26b1af2764f0f9783149" \
        "Padding-sensitive binary pattern 2"]

    :set res [$RunTestCase $res $GetSha512Sum ("\FF\FF\FF\FF\FF\FF\FF\80") "nothing" "nothing" \
        "bc49a51683e8fbc1fb98fbed3271fd9c61240095862fb289dbbebb4fde9976ce1db2ef582578c657c9ef4d5fbbe8ab9a125e89a099aa63c67d9a1c0b3bbb79ce" \
        "Padding-sensitive binary pattern 3"]

    :set res [$RunTestCase $res $GetSha512Sum ("\80\FF\FF\FF\FF\FF\FF\FF") "nothing" "nothing" \
        "53fc1994a7f4c0e6fa41a9e84a59d5c266e8095c0526e80e871011a2dfba845afaa45ab5929a54ab114a0dc1a7aff3dfc3f041b4e0fa0bf8cb415bb9ca3cc197" \
        "Padding-sensitive binary pattern 4"]

    :put "Testing completed."

    :return $res
}
