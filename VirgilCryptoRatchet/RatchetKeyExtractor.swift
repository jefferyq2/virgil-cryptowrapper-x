/// Copyright (C) 2015-2019 Virgil Security, Inc.
///
/// All rights reserved.
///
/// Redistribution and use in source and binary forms, with or without
/// modification, are permitted provided that the following conditions are
/// met:
///
///     (1) Redistributions of source code must retain the above copyright
///     notice, this list of conditions and the following disclaimer.
///
///     (2) Redistributions in binary form must reproduce the above copyright
///     notice, this list of conditions and the following disclaimer in
///     the documentation and/or other materials provided with the
///     distribution.
///
///     (3) Neither the name of the copyright holder nor the names of its
///     contributors may be used to endorse or promote products derived from
///     this software without specific prior written permission.
///
/// THIS SOFTWARE IS PROVIDED BY THE AUTHOR ''AS IS'' AND ANY EXPRESS OR
/// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
/// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
/// DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
/// INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
/// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
/// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
/// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
/// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
/// IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
/// POSSIBILITY OF SUCH DAMAGE.
///
/// Lead Maintainer: Virgil Security Inc. <support@virgilsecurity.com>


import Foundation
import VSCRatchet
import VirgilCryptoFoundation

/// Utils class for working with keys formats
@objc(VSCRRatchetKeyExtractor) public class RatchetKeyExtractor: NSObject {

    /// Handle underlying C context.
    @objc public let c_ctx: OpaquePointer

    /// Create underlying C context.
    public override init() {
        self.c_ctx = vscr_ratchet_key_extractor_new()
        super.init()
    }

    /// Acquire C context.
    /// Note. This method is used in generated code only, and SHOULD NOT be used in another way.
    public init(take c_ctx: OpaquePointer) {
        self.c_ctx = c_ctx
        super.init()
    }

    /// Acquire retained C context.
    /// Note. This method is used in generated code only, and SHOULD NOT be used in another way.
    public init(use c_ctx: OpaquePointer) {
        self.c_ctx = vscr_ratchet_key_extractor_shallow_copy(c_ctx)
        super.init()
    }

    /// Release underlying C context.
    deinit {
        vscr_ratchet_key_extractor_delete(self.c_ctx)
    }

    /// Computes 8 bytes key pair id from public key
    @objc public func computePublicKeyId(publicKey: Data, keyId: Data) throws -> Data {
        let keyIdCount = RatchetCommon.keyIdLen
        var keyId = Data(count: keyIdCount)
        var keyIdBuf = vsc_buffer_new()
        defer {
            vsc_buffer_delete(keyIdBuf)
        }

        let proxyResult = publicKey.withUnsafeBytes({ (publicKeyPointer: UnsafePointer<byte>) -> vscr_error_t in
            keyId.withUnsafeBytes({ (keyIdPointer: UnsafePointer<byte>) -> vscr_error_t in
                keyId.withUnsafeMutableBytes({ (keyIdPointer: UnsafeMutablePointer<byte>) -> vscr_error_t in
                    vsc_buffer_init(keyIdBuf)
                    vsc_buffer_use(keyIdBuf, keyIdPointer, keyIdCount)

                    var keyIdBuf = vsc_buffer_new_with_data(vsc_data(keyIdPointer, keyId.count))
                    defer {
                        vsc_buffer_delete(keyIdBuf)
                    }
                    return vscr_ratchet_key_extractor_compute_public_key_id(self.c_ctx, vsc_data(publicKeyPointer, publicKey.count), keyIdBuf)
                })
            })
        })
        keyId.count = vsc_buffer_len(keyIdBuf)

        try RatchetError.handleError(fromC: proxyResult)

        return keyId
    }

    @objc public func extractRatchetPublicKey(data: Data, errCtx: ErrorCtx) -> Data {
        let proxyResult = data.withUnsafeBytes({ (dataPointer: UnsafePointer<byte>) in
            return vscr_ratchet_key_extractor_extract_ratchet_public_key(self.c_ctx, vsc_data(dataPointer, data.count), errCtx.c_ctx)
        })

        defer {
            vsc_buffer_delete(proxyResult)
        }

        return Data.init(bytes: vsc_buffer_bytes(proxyResult), count: vsc_buffer_len(proxyResult))
    }

    @objc public func extractRatchetPrivateKey(data: Data, errCtx: ErrorCtx) -> Data {
        let proxyResult = data.withUnsafeBytes({ (dataPointer: UnsafePointer<byte>) in
            return vscr_ratchet_key_extractor_extract_ratchet_private_key(self.c_ctx, vsc_data(dataPointer, data.count), errCtx.c_ctx)
        })

        defer {
            vsc_buffer_delete(proxyResult)
        }

        return Data.init(bytes: vsc_buffer_bytes(proxyResult), count: vsc_buffer_len(proxyResult))
    }
}