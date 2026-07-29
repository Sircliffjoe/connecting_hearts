import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "fileInput", "previewContainer", "imagePreview", "videoPreview", "status", "progress", "badge"]

  connect() {
    this.checkInitialValue()
  }

  checkInitialValue() {
    if (this.hasInputTarget && this.inputTarget.value) {
      const url = this.inputTarget.value
      this.showPreviewForUrl(url)
    }
  }

  async handleFileSelect(event) {
    const file = event.target.files[0]
    if (!file) return

    const originalSizeKb = (file.size / 1024).toFixed(1)
    const isVideo = file.type.startsWith("video/")
    const isImage = file.type.startsWith("image/")

    if (this.hasPreviewContainerTarget) {
      this.previewContainerTarget.classList.remove("hidden")
    }

    if (isVideo) {
      this.handleVideoSelect(file, originalSizeKb)
    } else if (isImage) {
      this.handleImageSelect(file, originalSizeKb)
    } else {
      this.uploadFile(file, originalSizeKb, originalSizeKb)
    }
  }

  handleVideoSelect(file, originalSizeKb) {
    const videoUrl = URL.createObjectURL(file)

    if (this.hasVideoPreviewTarget) {
      this.videoPreviewTarget.src = videoUrl
      this.videoPreviewTarget.classList.remove("hidden")
    }
    if (this.hasImagePreviewTarget) {
      this.imagePreviewTarget.classList.add("hidden")
    }

    if (this.hasBadgeTarget) {
      this.badgeTarget.textContent = `Video selected • Size: ${originalSizeKb} KB`
      this.badgeTarget.className = "px-2.5 py-1 rounded-full text-[10px] font-bold bg-amber-900/60 text-amber-300 border border-amber-700"
    }

    this.uploadFile(file, originalSizeKb, originalSizeKb)
  }

  async handleImageSelect(file, originalSizeKb) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = `Compressing image (${originalSizeKb} KB)...`
    }

    try {
      const compressedBlob = await this.compressImageToKb(file, 400) // Compress target max 400KB
      const compressedSizeKb = (compressedBlob.size / 1024).toFixed(1)

      const previewUrl = URL.createObjectURL(compressedBlob)
      if (this.hasImagePreviewTarget) {
        this.imagePreviewTarget.src = previewUrl
        this.imagePreviewTarget.classList.remove("hidden")
      }
      if (this.hasVideoPreviewTarget) {
        this.videoPreviewTarget.classList.add("hidden")
      }

      if (this.hasBadgeTarget) {
        this.badgeTarget.textContent = `Original: ${originalSizeKb} KB → Compressed: ${compressedSizeKb} KB`
        this.badgeTarget.className = "px-2.5 py-1 rounded-full text-[10px] font-bold bg-emerald-900/60 text-emerald-300 border border-emerald-700"
      }

      const compressedFile = new File([compressedBlob], file.name, { type: "image/jpeg" })
      this.uploadFile(compressedFile, originalSizeKb, compressedSizeKb)
    } catch (err) {
      console.error("Compression error, uploading original:", err)
      this.uploadFile(file, originalSizeKb, originalSizeKb)
    }
  }

  compressImageToKb(file, targetMaxKb = 400) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader()
      reader.readAsDataURL(file)
      reader.onload = (e) => {
        const img = new Image()
        img.src = e.target.result
        img.onload = () => {
          const canvas = document.createElement("canvas")
          let width = img.width
          let height = img.height
          const maxDim = 1920

          if (width > maxDim || height > maxDim) {
            if (width > height) {
              height = Math.round((height * maxDim) / width)
              width = maxDim
            } else {
              width = Math.round((width * maxDim) / height)
              height = maxDim
            }
          }

          canvas.width = width
          canvas.height = height

          const ctx = canvas.getContext("2d")
          ctx.drawImage(img, 0, 0, width, height)

          let quality = 0.85
          const attemptCompress = (q) => {
            canvas.toBlob(
              (blob) => {
                if (!blob) {
                  reject(new Error("Canvas blob creation failed"))
                  return
                }
                const sizeKb = blob.size / 1024
                if (sizeKb > targetMaxKb && q > 0.3) {
                  attemptCompress(q - 0.15)
                } else {
                  resolve(blob)
                }
              },
              "image/jpeg",
              q
            )
          }

          attemptCompress(quality)
        }
        img.onerror = reject
      }
      reader.onerror = reject
    })
  }

  async uploadFile(file, originalSizeKb, compressedSizeKb) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = `Uploading to Cloudinary (${compressedSizeKb} KB)...`
    }
    if (this.hasProgressTarget) {
      this.progressTarget.style.width = "40%"
      this.progressTarget.classList.remove("hidden")
    }

    const formData = new FormData()
    formData.append("file", file)

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    try {
      const response = await fetch("/admin/uploads", {
        method: "POST",
        headers: {
          "X-CSRF-Token": csrfToken || "",
        },
        body: formData,
      })

      const data = await response.json()

      if (response.ok && data.success && data.url) {
        if (this.hasInputTarget) {
          this.inputTarget.value = data.url
        }
        if (this.hasStatusTarget) {
          this.statusTarget.textContent = "✓ Uploaded to Cloudinary successfully!"
        }
        if (this.hasProgressTarget) {
          this.progressTarget.style.width = "100%"
          setTimeout(() => this.progressTarget.classList.add("hidden"), 1000)
        }
      } else {
        throw new Error(data.error || "Upload failed")
      }
    } catch (err) {
      console.error("Upload error:", err)
      if (this.hasStatusTarget) {
        this.statusTarget.textContent = `Upload failed: ${err.message}`
      }
      if (this.hasProgressTarget) {
        this.progressTarget.classList.add("hidden")
      }
    }
  }

  showPreviewForUrl(url) {
    if (!url) return
    if (this.hasPreviewContainerTarget) {
      this.previewContainerTarget.classList.remove("hidden")
    }

    const isVideo = url.match(/\.(mp4|webm|ogg|mov)($|\?)/i)
    if (isVideo) {
      if (this.hasVideoPreviewTarget) {
        this.videoPreviewTarget.src = url
        this.videoPreviewTarget.classList.remove("hidden")
      }
      if (this.hasImagePreviewTarget) {
        this.imagePreviewTarget.classList.add("hidden")
      }
    } else {
      if (this.hasImagePreviewTarget) {
        this.imagePreviewTarget.src = url
        this.imagePreviewTarget.classList.remove("hidden")
      }
      if (this.hasVideoPreviewTarget) {
        this.videoPreviewTarget.classList.add("hidden")
      }
    }
  }

  clearPreview() {
    if (this.hasInputTarget) {
      this.inputTarget.value = ""
    }
    if (this.hasFileInputTarget) {
      this.fileInputTarget.value = ""
    }
    if (this.hasPreviewContainerTarget) {
      this.previewContainerTarget.classList.add("hidden")
    }
    if (this.hasImagePreviewTarget) {
      this.imagePreviewTarget.src = ""
      this.imagePreviewTarget.classList.add("hidden")
    }
    if (this.hasVideoPreviewTarget) {
      this.videoPreviewTarget.src = ""
      this.videoPreviewTarget.classList.add("hidden")
    }
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = ""
    }
  }
}
