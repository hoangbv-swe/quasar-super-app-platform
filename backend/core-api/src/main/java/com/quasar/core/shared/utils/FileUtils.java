package com.quasar.core.shared.utils;

import org.apache.commons.io.FilenameUtils;
import org.springframework.web.multipart.MultipartFile;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

public final class FileUtils {
    private static final List<String> ALLOWED_EXTENSIONS = Arrays.asList("jpg", "jpeg", "png", "gif", "bmp", "webp");
    private static final long MAX_FILE_SIZE = 5 * 1024 * 1024;

    private FileUtils() {
        throw new UnsupportedOperationException("Utility class");
    }

    public static boolean isImageFile(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            return false;
        }

        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            return false;
        }

        String extension = FilenameUtils.getExtension(file.getOriginalFilename());
        return extension != null && ALLOWED_EXTENSIONS.contains(extension.toLowerCase());
    }

    public static String storeFile(MultipartFile file, String uploadDir) throws IOException {
        if (!isImageFile(file) || file.getOriginalFilename() == null) {
            throw new IllegalArgumentException("Định dạng file không hợp lệ. Chỉ chấp nhận file ảnh.");
        }

        if (file.getSize() > MAX_FILE_SIZE) {
            throw new IllegalArgumentException("Dung lượng ảnh không được vượt quá 5MB.");
        }

        String extension = FilenameUtils.getExtension(file.getOriginalFilename());
        String uniqueFilename = System.currentTimeMillis() + "_" + UUID.randomUUID().toString().substring(0, 8) + "." + extension;

        Path uploadPath = Paths.get(uploadDir).toAbsolutePath().normalize();
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        Path destination = uploadPath.resolve(uniqueFilename).normalize();
        if (!destination.startsWith(uploadPath)) {
            throw new SecurityException("Security Error: Path traversal attempt detected.");
        }

        try (var inputStream = file.getInputStream()) {
            Files.copy(inputStream, destination, StandardCopyOption.REPLACE_EXISTING);
        }

        return uniqueFilename;
    }

    public static void deleteFile(String filename, String uploadDir) throws IOException {
        Path uploadPath = Paths.get(uploadDir).toAbsolutePath().normalize();
        Path filePath = uploadPath.resolve(filename).normalize();

        if (!filePath.startsWith(uploadPath)) {
            throw new SecurityException("Security Error: Path traversal attempt detected.");
        }

        if (!Files.deleteIfExists(filePath)) {
            throw new FileNotFoundException("File không tồn tại: " + filename);
        }
    }
}
