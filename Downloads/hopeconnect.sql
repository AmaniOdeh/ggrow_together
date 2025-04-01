-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 01, 2025 at 09:53 PM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `hopeconnect`
--

-- --------------------------------------------------------

--
-- Table structure for table `activities`
--

CREATE TABLE `activities` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `orphanage_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `activity_schedule`
--

CREATE TABLE `activity_schedule` (
  `id` int(11) NOT NULL,
  `activity_id` int(11) DEFAULT NULL,
  `scheduled_date` date NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `location` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `admins`
--

CREATE TABLE `admins` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `is_super` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admins`
--

INSERT INTO `admins` (`id`, `user_id`, `is_super`, `created_at`) VALUES
(4, 20, 1, '2025-03-29 02:05:42');

-- --------------------------------------------------------

--
-- Table structure for table `donations`
--

CREATE TABLE `donations` (
  `id` int(11) NOT NULL,
  `donor_id` int(11) DEFAULT NULL,
  `orphan_id` int(11) DEFAULT NULL,
  `room_id` int(11) DEFAULT NULL,
  `orphanage_id` int(11) DEFAULT NULL,
  `type` enum('money','clothes','food','books','medical aid') NOT NULL,
  `amount` decimal(10,2) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `status` enum('pending','approved','delivered') DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `emergency_campaign_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `donations`
--

INSERT INTO `donations` (`id`, `donor_id`, `orphan_id`, `room_id`, `orphanage_id`, `type`, `amount`, `description`, `status`, `created_at`, `emergency_campaign_id`) VALUES
(5, 1, 2, 1, 1, 'money', 1000.00, 'Updated monthly donation', 'pending', '2025-04-01 15:31:02', NULL),
(6, 2, 2, 1, 1, 'money', 150.00, 'Monthly financial support', 'pending', '2025-04-01 15:33:29', NULL),
(9, 3, 2, 1, 1, '', 450.00, 'Updated monthly donation ', 'pending', '2025-04-01 17:27:21', NULL),
(17, 3, 2, 3, 1, '', 100.00, 'Books & School Fees', 'pending', '2025-04-01 18:17:12', NULL),
(18, 3, 2, 3, 1, '', 100.00, 'Books & School Fees', 'pending', '2025-04-01 18:20:21', NULL),
(19, 3, 2, 3, 1, '', 100.00, 'Books & School Fees', 'pending', '2025-04-01 18:21:21', NULL),
(20, 3, 2, 3, 1, '', 100.00, 'Books & School Fees', 'pending', '2025-04-01 18:23:00', NULL),
(21, 3, 2, 3, 1, '', 100.00, 'Books & School Fees', 'pending', '2025-04-01 18:30:06', NULL),
(22, 3, 2, 3, 1, '', 100.00, 'Books & School Fees', 'pending', '2025-04-01 18:31:52', NULL),
(23, 3, 2, 3, 1, '', 100.00, 'Books & School Fees', 'pending', '2025-04-01 18:34:36', NULL),
(24, 3, 2, 3, 1, '', 100.00, 'Books & School Fees', 'pending', '2025-04-01 18:41:05', NULL),
(32, 3, 2, 3, 1, '', 100.00, 'Books & School Fees', 'pending', '2025-04-01 19:10:19', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `donors`
--

CREATE TABLE `donors` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `orphanage_id` int(11) DEFAULT NULL,
  `total_donations` int(11) DEFAULT 0,
  `total_amount` decimal(10,2) DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `donors`
--

INSERT INTO `donors` (`id`, `user_id`, `orphanage_id`, `total_donations`, `total_amount`) VALUES
(1, 12, NULL, 0, 0.00),
(2, 21, NULL, 0, 0.00),
(3, 22, NULL, 0, 0.00);

-- --------------------------------------------------------

--
-- Table structure for table `emergency_campaigns`
--

CREATE TABLE `emergency_campaigns` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `target_amount` decimal(10,2) DEFAULT NULL,
  `current_amount` decimal(10,2) DEFAULT 0.00,
  `status` enum('open','closed') DEFAULT 'open',
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `orphanages`
--

CREATE TABLE `orphanages` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `address` text NOT NULL,
  `contact_phone` varchar(20) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `orphanages`
--

INSERT INTO `orphanages` (`id`, `name`, `address`, `contact_phone`, `created_at`) VALUES
(1, 'بيت الأمل', 'نابلس - شارع الجامعة', '0591234567', '2025-03-22 06:10:48');

-- --------------------------------------------------------

--
-- Table structure for table `orphans`
--

CREATE TABLE `orphans` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `age` int(11) NOT NULL,
  `education_status` text DEFAULT NULL,
  `health_condition` text DEFAULT NULL,
  `room_id` int(11) DEFAULT NULL,
  `orphanage_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `orphans`
--

INSERT INTO `orphans` (`id`, `user_id`, `age`, `education_status`, `health_condition`, `room_id`, `orphanage_id`) VALUES
(2, 11, 12, 'متوسط', 'جيد', 1, 1),
(3, 15, 11, 'Primary', 'Good', 1, 1);

-- --------------------------------------------------------

--
-- Table structure for table `orphan_activities`
--

CREATE TABLE `orphan_activities` (
  `id` int(11) NOT NULL,
  `orphan_id` int(11) DEFAULT NULL,
  `schedule_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `orphan_reports`
--

CREATE TABLE `orphan_reports` (
  `id` int(11) NOT NULL,
  `orphan_id` int(11) NOT NULL,
  `report_type` enum('Health','Education','Progress','Other') NOT NULL,
  `description` text DEFAULT NULL,
  `photo_url` varchar(255) DEFAULT NULL,
  `report_date` date NOT NULL DEFAULT curdate()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `orphan_reports`
--

INSERT INTO `orphan_reports` (`id`, `orphan_id`, `report_type`, `description`, `photo_url`, `report_date`) VALUES
(2, 2, '', 'Updated report about the orphan\'s education condition123456.', 'https://example.com/photo.jpg', '2025-03-29'),
(3, 2, '', 'Yousef\'s health condition is improving.', 'https://example.com/photo.jpg', '2025-03-29'),
(4, 2, '', 'Yousef\'s health condition is improving.', 'https://example.com/photo.jpg', '2025-03-29'),
(5, 2, '', 'Yousef\'s health condition is improving.', 'https://example.com/photo.jpg', '2025-03-29');

-- --------------------------------------------------------

--
-- Table structure for table `rooms`
--

CREATE TABLE `rooms` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `orphanage_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `rooms`
--

INSERT INTO `rooms` (`id`, `name`, `description`, `orphanage_id`) VALUES
(1, 'غرفة 1', 'غرفة للأطفال من عمر 2 إلى 3 سنوات', 1),
(2, 'غرفة 2', 'غرفة للأطفال من عمر 4 إلى 5 سنوات', 1),
(3, 'غرفة 3', 'غرفة للأطفال من عمر 6 إلى 8 سنوات', 1),
(4, 'غرفة 4', 'غرفة للأطفال من عمر 9 إلى 11 سنة', 1),
(5, 'غرفة 5', 'غرفة للأطفال من عمر 12 إلى 14 سنة', 1);

-- --------------------------------------------------------

--
-- Table structure for table `sponsors`
--

CREATE TABLE `sponsors` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `orphanage_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `sponsors`
--

INSERT INTO `sponsors` (`id`, `user_id`, `orphanage_id`, `created_at`) VALUES
(1, 13, NULL, '2025-03-22 22:51:23');

-- --------------------------------------------------------

--
-- Table structure for table `sponsorships`
--

CREATE TABLE `sponsorships` (
  `id` int(11) NOT NULL,
  `sponsor_id` int(11) DEFAULT NULL,
  `orphan_id` int(11) DEFAULT NULL,
  `orphanage_id` int(11) DEFAULT NULL,
  `monthly_amount` decimal(10,2) NOT NULL,
  `start_date` date NOT NULL,
  `status` enum('active','paused','cancelled') DEFAULT 'active',
  `sponsorship_type_id` int(11) DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `sponsorships`
--

INSERT INTO `sponsorships` (`id`, `sponsor_id`, `orphan_id`, `orphanage_id`, `monthly_amount`, `start_date`, `status`, `sponsorship_type_id`, `end_date`, `notes`) VALUES
(4, 1, 2, 1, 120.00, '2025-04-01', 'active', 1, '2025-03-30', 'Updated amount'),
(5, 1, 2, 1, 100.00, '2025-04-01', 'active', 1, '2025-04-02', 'Educational Sponsorship'),
(6, 1, 2, 1, 120.00, '2025-04-01', 'active', 1, '2025-12-31', 'Full sponsorship'),
(7, 1, 2, 1, 100.00, '2025-04-01', 'active', 1, '2025-12-01', 'Educational Sponsorship');

-- --------------------------------------------------------

--
-- Table structure for table `sponsorship_types`
--

CREATE TABLE `sponsorship_types` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `sponsorship_types`
--

INSERT INTO `sponsorship_types` (`id`, `name`, `description`) VALUES
(1, 'Full Sponsorship', 'Covers all basic needs of the orphan'),
(2, 'Education', 'Covers tuition fees, school supplies, and education needs'),
(3, 'Health', 'Covers medical check-ups and treatments'),
(4, 'Monthly Support', 'General monthly contribution to the orphan');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('orphan','donor','volunteer','admin','sponsor') NOT NULL,
  `orphanage_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `phone_number`, `email`, `password`, `role`, `orphanage_id`, `created_at`) VALUES
(3, 'Khaled Sponsor', '0598888888', 'khaled@sponsor.com', '$2b$10$ZanH9WbJkLkvjvQkQVfXIO9/ZO5w6DwjMuxWOnU9/qWhZn4pp3E0i', 'sponsor', NULL, '2025-03-22 06:18:08'),
(5, 'Hana Volunteer', '0597777777', 'hana.vol@example.com', '$2b$10$AIVXpq0d8N97rpPoedV9NOWOvJVV6nmsuHaJEeKDEsm8jrg8EPwnW', 'volunteer', NULL, '2025-03-22 06:28:02'),
(11, 'Yousef Orphan', '0599999999', 'yousef.orphan123@example.com', '$2b$10$k1mXI40KXC.BD4hb5vSwiu0m2G9VHoAQywRdlLnExXwER22pLNsN6', 'orphan', 1, '2025-03-22 12:24:28'),
(12, 'Ahmed Donor', '0599123456', 'ahmed.donor@example.com', '$2b$10$qWXYaZoygAmUxb5/QQayduNRHT0QNx0ZUneqlXLmClnCBwO6cKqR.', 'donor', NULL, '2025-03-22 12:26:57'),
(13, 'Mona Sponsor', '0599234567', 'amoon7859@gmail.com', '$2b$10$pbV/gZE9ePseCLNN13CSU.bsBibRyB8xWoH6V0FuhhhxyyW.GtzBW', 'sponsor', NULL, '2025-03-22 12:27:11'),
(15, 'Yousef Orphan', '0599456789', 'yousef.orphan@example.com', '$2b$10$siDekQ/qv6cpzcLZSEtBTeOXqsnVYA7FMyrNeDqZE1nKTwy.sydiC', 'orphan', 1, '2025-03-22 12:28:33'),
(16, 'Ali Volunteer', '0599345678', 'ali.vol@example.com', '$2b$10$/3Xoa4meCPChU0YlUdSv3OiETbzn1LaisxaqVvImnIcTu2W0xjCeO', 'volunteer', NULL, '2025-03-22 12:31:31'),
(20, 'Amani Odeh', '0599999999', 'amaniodeh225@gmail.com', '$2b$10$NghAyPEOiQLmZZfecNHc2eAi2WcMGWcRBEAFEW0tJKDeRePQbz/L2', 'admin', NULL, '2025-03-29 02:05:42'),
(21, 'Donor User', '0599999999', 'donor@example.com', '$2b$10$x3bH7OApcB/eY63PXa1qDeYmon06.ZTf1qNaB7fQjIHfkePREpvry', 'donor', NULL, '2025-04-01 15:32:51'),
(22, 'Donor User12', '0591111111', 'amanideek9@gmail.com', '$2b$10$7nsVN.1RVSJwpO5H13Oq..Xdr1I0Ecsy760vbgpVRNyqaDDB5jh0S', 'donor', NULL, '2025-04-01 15:38:52');

-- --------------------------------------------------------

--
-- Table structure for table `volunteers`
--

CREATE TABLE `volunteers` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `type_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `volunteers`
--

INSERT INTO `volunteers` (`id`, `user_id`, `type_id`) VALUES
(2, 16, 2);

-- --------------------------------------------------------

--
-- Table structure for table `volunteer_activities`
--

CREATE TABLE `volunteer_activities` (
  `id` int(11) NOT NULL,
  `volunteer_id` int(11) DEFAULT NULL,
  `orphanage_id` int(11) DEFAULT NULL,
  `schedule_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `volunteer_types`
--

CREATE TABLE `volunteer_types` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `volunteer_types`
--

INSERT INTO `volunteer_types` (`id`, `name`) VALUES
(1, 'Teaching'),
(2, 'Entertainment'),
(3, 'Medical');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `activities`
--
ALTER TABLE `activities`
  ADD PRIMARY KEY (`id`),
  ADD KEY `orphanage_id` (`orphanage_id`);

--
-- Indexes for table `activity_schedule`
--
ALTER TABLE `activity_schedule`
  ADD PRIMARY KEY (`id`),
  ADD KEY `activity_id` (`activity_id`);

--
-- Indexes for table `admins`
--
ALTER TABLE `admins`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `donations`
--
ALTER TABLE `donations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `donor_id` (`donor_id`),
  ADD KEY `orphan_id` (`orphan_id`),
  ADD KEY `room_id` (`room_id`),
  ADD KEY `orphanage_id` (`orphanage_id`),
  ADD KEY `fk_emergency_campaign` (`emergency_campaign_id`);

--
-- Indexes for table `donors`
--
ALTER TABLE `donors`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`),
  ADD KEY `orphanage_id` (`orphanage_id`);

--
-- Indexes for table `emergency_campaigns`
--
ALTER TABLE `emergency_campaigns`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `orphanages`
--
ALTER TABLE `orphanages`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `orphans`
--
ALTER TABLE `orphans`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`),
  ADD KEY `room_id` (`room_id`),
  ADD KEY `orphanage_id` (`orphanage_id`);

--
-- Indexes for table `orphan_activities`
--
ALTER TABLE `orphan_activities`
  ADD PRIMARY KEY (`id`),
  ADD KEY `orphan_id` (`orphan_id`),
  ADD KEY `schedule_id` (`schedule_id`);

--
-- Indexes for table `orphan_reports`
--
ALTER TABLE `orphan_reports`
  ADD PRIMARY KEY (`id`),
  ADD KEY `orphan_id` (`orphan_id`);

--
-- Indexes for table `rooms`
--
ALTER TABLE `rooms`
  ADD PRIMARY KEY (`id`),
  ADD KEY `orphanage_id` (`orphanage_id`);

--
-- Indexes for table `sponsors`
--
ALTER TABLE `sponsors`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`),
  ADD KEY `orphanage_id` (`orphanage_id`);

--
-- Indexes for table `sponsorships`
--
ALTER TABLE `sponsorships`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sponsor_id` (`sponsor_id`),
  ADD KEY `orphan_id` (`orphan_id`),
  ADD KEY `orphanage_id` (`orphanage_id`),
  ADD KEY `fk_sponsorship_type` (`sponsorship_type_id`);

--
-- Indexes for table `sponsorship_types`
--
ALTER TABLE `sponsorship_types`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `orphanage_id` (`orphanage_id`);

--
-- Indexes for table `volunteers`
--
ALTER TABLE `volunteers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `type_id` (`type_id`);

--
-- Indexes for table `volunteer_activities`
--
ALTER TABLE `volunteer_activities`
  ADD PRIMARY KEY (`id`),
  ADD KEY `volunteer_id` (`volunteer_id`),
  ADD KEY `orphanage_id` (`orphanage_id`),
  ADD KEY `schedule_id` (`schedule_id`);

--
-- Indexes for table `volunteer_types`
--
ALTER TABLE `volunteer_types`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `activities`
--
ALTER TABLE `activities`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `activity_schedule`
--
ALTER TABLE `activity_schedule`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `admins`
--
ALTER TABLE `admins`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `donations`
--
ALTER TABLE `donations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `donors`
--
ALTER TABLE `donors`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `emergency_campaigns`
--
ALTER TABLE `emergency_campaigns`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `orphanages`
--
ALTER TABLE `orphanages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `orphans`
--
ALTER TABLE `orphans`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `orphan_activities`
--
ALTER TABLE `orphan_activities`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `orphan_reports`
--
ALTER TABLE `orphan_reports`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `rooms`
--
ALTER TABLE `rooms`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `sponsors`
--
ALTER TABLE `sponsors`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `sponsorships`
--
ALTER TABLE `sponsorships`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `sponsorship_types`
--
ALTER TABLE `sponsorship_types`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `volunteers`
--
ALTER TABLE `volunteers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `volunteer_activities`
--
ALTER TABLE `volunteer_activities`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `volunteer_types`
--
ALTER TABLE `volunteer_types`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `activities`
--
ALTER TABLE `activities`
  ADD CONSTRAINT `activities_ibfk_1` FOREIGN KEY (`orphanage_id`) REFERENCES `orphanages` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `activity_schedule`
--
ALTER TABLE `activity_schedule`
  ADD CONSTRAINT `activity_schedule_ibfk_1` FOREIGN KEY (`activity_id`) REFERENCES `activities` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `admins`
--
ALTER TABLE `admins`
  ADD CONSTRAINT `admins_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `donations`
--
ALTER TABLE `donations`
  ADD CONSTRAINT `donations_ibfk_1` FOREIGN KEY (`donor_id`) REFERENCES `donors` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `donations_ibfk_2` FOREIGN KEY (`orphan_id`) REFERENCES `orphans` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `donations_ibfk_3` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `donations_ibfk_4` FOREIGN KEY (`orphanage_id`) REFERENCES `orphanages` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_emergency_campaign` FOREIGN KEY (`emergency_campaign_id`) REFERENCES `emergency_campaigns` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `donors`
--
ALTER TABLE `donors`
  ADD CONSTRAINT `donors_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `donors_ibfk_2` FOREIGN KEY (`orphanage_id`) REFERENCES `orphanages` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `orphans`
--
ALTER TABLE `orphans`
  ADD CONSTRAINT `orphans_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `orphans_ibfk_2` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `orphans_ibfk_3` FOREIGN KEY (`orphanage_id`) REFERENCES `orphanages` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `orphan_activities`
--
ALTER TABLE `orphan_activities`
  ADD CONSTRAINT `orphan_activities_ibfk_1` FOREIGN KEY (`orphan_id`) REFERENCES `orphans` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `orphan_activities_ibfk_2` FOREIGN KEY (`schedule_id`) REFERENCES `activity_schedule` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `orphan_reports`
--
ALTER TABLE `orphan_reports`
  ADD CONSTRAINT `orphan_reports_ibfk_1` FOREIGN KEY (`orphan_id`) REFERENCES `orphans` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `rooms`
--
ALTER TABLE `rooms`
  ADD CONSTRAINT `rooms_ibfk_1` FOREIGN KEY (`orphanage_id`) REFERENCES `orphanages` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `sponsors`
--
ALTER TABLE `sponsors`
  ADD CONSTRAINT `sponsors_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `sponsors_ibfk_2` FOREIGN KEY (`orphanage_id`) REFERENCES `orphanages` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `sponsorships`
--
ALTER TABLE `sponsorships`
  ADD CONSTRAINT `fk_sponsorship_type` FOREIGN KEY (`sponsorship_type_id`) REFERENCES `sponsorship_types` (`id`),
  ADD CONSTRAINT `sponsorships_ibfk_1` FOREIGN KEY (`sponsor_id`) REFERENCES `sponsors` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `sponsorships_ibfk_2` FOREIGN KEY (`orphan_id`) REFERENCES `orphans` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `sponsorships_ibfk_3` FOREIGN KEY (`orphanage_id`) REFERENCES `orphanages` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_ibfk_1` FOREIGN KEY (`orphanage_id`) REFERENCES `orphanages` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `volunteers`
--
ALTER TABLE `volunteers`
  ADD CONSTRAINT `volunteers_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `volunteers_ibfk_2` FOREIGN KEY (`type_id`) REFERENCES `volunteer_types` (`id`);

--
-- Constraints for table `volunteer_activities`
--
ALTER TABLE `volunteer_activities`
  ADD CONSTRAINT `volunteer_activities_ibfk_1` FOREIGN KEY (`volunteer_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `volunteer_activities_ibfk_2` FOREIGN KEY (`orphanage_id`) REFERENCES `orphanages` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `volunteer_activities_ibfk_3` FOREIGN KEY (`schedule_id`) REFERENCES `activity_schedule` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
